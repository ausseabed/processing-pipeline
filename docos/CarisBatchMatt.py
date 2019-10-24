"""
CarisBatch.py - a callable class that automatically sets the environment and
executes Caris HIPS and SIPS and Caris Base Editor processes using the
the CarisBatch command line utility

@author: Matt Boyd
"""

import os
import sys
import re
import datetime
import subprocess
import time
from Queue import Queue
from itertools import islice
from threading import Thread, Event

from nturl2path import pathname2url

class CarisBatch:
    """CarisBatch QObject.
    
    dataSignal-Connect to this signal for output
    errorSignal-Connect to this signal for error output
    lineQueue-A queue to work through conversion of lines
    processQueue-A queue to process the lines that have been converted 
    
    """
       
    dateFormat = '%Y%m%d'
    dataSignal = pyqtSignal(str)
    errorSignal = pyqtSignal(str)
    lineQueue = Queue()
    processQueue = Queue()
    
    def __init__(self, args=[], kwargs=None):
        super(CarisBatch, self).__init__()
        self.args = args
        self.kwargs = kwargs
        self.delay = Event()
        self.delayThread = Thread(target=self.waiting, args=(self.delay,))
        self.delayThread.daemon = True
        self.delayThread.start()
        self.carisThread = Thread(target=self.executeBatch, args=(self.delay,))
        self.carisThread.daemon = True
        self.carisThread.start()
        self.tide = 'NONE'
        
    def __call__(self, *args, **kwargs):
        self.args = args
        self.kwargs = kwargs
        
        if 'HIPSandSIPSInstall' in kwargs:
            self.setEnv(kwargs['HIPSandSIPSInstall'])
        if 'BaseEditorInstall' in kwargs:
            self.setEnv(kwargs['BaseEditorInstall'])
        else:
            self.setEnv()   
        
        if os.path.splitext(kwargs['Path'])[1] == '.all':
            if self.lineQueue.empty():
                self.dayList = []
                self.lineQueue.put(kwargs['Path'])
                self.initialDayURI = self.setPath(kwargs['Path'])[1]
                self.processRoot = self.setPath(kwargs['Path'])[4] + '?'
            else:
                self.lineQueue.put(kwargs['Path'])
            
    def waiting(self, delayEvent):
        while True:
            if self.lineQueue.qsize() == 1:
                time.sleep(15)
                delayEvent.set()
            if self.lineQueue.empty() and self.processQueue.empty():
                delayEvent.clear()
            

    def setEnv(self, hipsandsips='C:\Program Files\CARIS\HIPS and SIPS',
               baseeditor='C:\Program Files\CARIS\BASE Editor'):
        self.hipsBatchLocation = os.path.join(hipsandsips,
                                              min(os.listdir(hipsandsips)),
                                              'bin',
                                              'carisbatch.exe')
        self.baseBatchLocation = os.path.join(baseeditor,
                                              max(os.listdir(baseeditor)),
                                              'bin',
                                              'carisbatch.exe')
        self.env = os.environ.copy()
        paths = [hipsandsips,baseeditor]
        envItems = []
        for path in paths:
            if os.path.isdir(path):
                path = os.path.join(path,max(os.listdir(path)))
                installFolder = os.path.join(path,'system')
                modulesFolder = os.path.join(path,'modules')
                envItems.append(os.path.join(installFolder,'..','bin'))
                for dirs in os.listdir(modulesFolder):
                    envItems.append(os.path.join(installFolder,'..','modules',dirs,'bin'))
        envString = ';' + ';'.join(envItems)
        self.env['PATH'] = self.env['PATH'] + envString
    
    def setPath(self, path):
        rawDirectory = path
        line = re.sub('.all', '', os.path.split(path)[1])
        project = re.split('/', os.path.dirname(path))[1]
        invProcessPath = '/Processing/CARIS/HDCS_Data/'
        invProductsPath = '/Products/Caris_Exports/'
        processDirectory = 'D:' + project + invProcessPath + project + '/' + project + '.hips'
        processRoot = 'file:' + pathname2url(processDirectory)
        tt = datetime.datetime.strptime(re.split('[_.]',
                                                        os.path.split(path)[1])[1],
                                               CarisBatch.dateFormat).timetuple()
        vessel = re.split('[_.]',
                               os.path.split(path)[1])[3] + '_' + re.split('[_.]',
                               os.path.split(path)[1])[4]
        jDay = str(tt.tm_year) + '-' + "{0:0>3}".format(str(tt.tm_yday))
        lineQuery = 'Vessel=' + vessel + ';Day=' + jDay + ';Line=' + line
        dayQuery = 'Vessel=' + vessel + ';Day=' + jDay
        dayURI = 'file:' + pathname2url(processDirectory) + '?Vessel=' + vessel + ';Day=' + jDay
        self.invPointExport = 'D:/' + project + invProductsPath + 'Point Cloud/' + project + '_' + vessel
        return rawDirectory, dayURI, lineQuery, dayQuery, processRoot
        
    def executeBatch(self, delayEvent):
            while True:
                delayEvent.wait()
                self.importToHIPS()
                if self.lineQueue.empty():
                    self.processHIPS()
                    
       
    def importToHIPS(self):
        if 'ImportToHIPS' in self.args:
            ImportToHIPS = [self.hipsBatchLocation,
                            "-r",
                            "ImportToHIPS",
                            "-l",
                            self.kwargs['DataType'],
                            "-N",
                            "--gps-height-device",
                            self.kwargs['GPSHeight']]
            raw, URI, line, day = self.setPath(self.lineQueue.get())[0:4]
            ImportToHIPS.append(raw)
            ImportToHIPS.append(URI)
            print ImportToHIPS
            self.runCommand(ImportToHIPS)
        else:
            raw, URI, line, day = self.setPath(self.lineQueue.get())[0:4]
        if URI == self.initialDayURI:
            self.processRoot += line + '&'
            if self.lineQueue.empty():
                self.processQueue.put(str(self.processRoot[:-1]))
        if URI != self.initialDayURI:
            if day not in self.dayList:
                self.processRoot += day + '&'
                self.dayList.append(day)
            if self.lineQueue.empty():
                self.processQueue.put(str(self.processRoot[:-1]))
                self.dayList = []
                
    def importTideToHIPS(self, item):
        ImportTideToHIPS = [self.hipsBatchLocation,
                            "-r",
                            "ImportTideToHIPS",
                            "--tide-file",
                            self.kwargs['TidePath']]
        ImportTideToHIPS.append(item)
        print ImportTideToHIPS
        self.runCommand(ImportTideToHIPS)
        
    def importHIPSFromAuxiliary(self, item):
        ImportHIPSFromAuxiliary = [self.hipsBatchLocation,
                                   "-r",
                                   "ImportHIPSFromAuxiliary",
                                   "-I",
                                   self.kwargs['AuxImportFormat'],
                                   "--reference-week",
                                   self.kwargs['ReferenceWeek'],
                                   "--navigation",
                                   "--gyro",
                                   "0sec",
                                   "--pitch",
                                   "0sec",
                                   "--roll",
                                   "0sec",
                                   "--gps-height",
                                   "0sec",
                                   self.kwargs['AuxFilePath']]
        ImportHIPSFromAuxiliary.append(item)
        print ImportHIPSFromAuxiliary
        self.runCommand(ImportHIPSFromAuxiliary)

    def computeHIPSGPSTide(self, item):
        ComputeHIPSGPSTide = [self.hipsBatchLocation,
                              "-r",
                              "ComputeHIPSGPSTide",
                              "--datum-separation-type",
                              "MODEL",
                              "--datum-model-file",
                              self.kwargs['ModelPath'],
                              "-s",
                              self.kwargs['InfoPath'],
                              "-p",
                              "EPSG:4283",
                              "--dynamic-heave",
                              self.kwargs['DynamicHeave'],
                              "--waterline",
                              self.kwargs['Waterline']]
        ComputeHIPSGPSTide.append(item)
        print ComputeHIPSGPSTide
        self.runCommand(ComputeHIPSGPSTide)
        
    def filterHIPSAttitude(self, item):
        FilterHIPSAttitude = [self.hipsBatchLocation,
                              "-r",
                              "FilterHIPSAttitude",
                              "-S",
                              self.kwargs['SensorType'],
                              "--enable-smoothing",
                              "--filter-type",
                              self.kwargs['SmoothingType'],
                              "--window-size-type",
                              self.kwargs['WindowType'],
                              "--window-size-time"]
        if self.kwargs['WindowType'] == 'SECONDS':
            FilterHIPSAttitude.append(self.kwargs['WindowSizeT'])
        else:
            FilterHIPSAttitude.append(self.kwargs['WindowSizeP'])
        FilterHIPSAttitude.append(item)
        print FilterHIPSAttitude
        self.runCommand(FilterHIPSAttitude)

    def soundVelocityCorrectHIPS(self, item):
        SoundVelocityCorrectHIPS = [self.hipsBatchLocation,
                                    "-r",
                                    "SoundVelocityCorrectHIPS",
                                    "-a",
                                    self.kwargs['Algorithm'],
                                    "-F",
                                    self.kwargs['SVPath'],
                                    "--profile-selection-method",
                                    self.kwargs['ProfileSelection'],
                                    "--heave-source",
                                    self.kwargs['SVHeaveSource']]
        SoundVelocityCorrectHIPS.append(item)
        print SoundVelocityCorrectHIPS
        self.runCommand(SoundVelocityCorrectHIPS)
        
    def mergeHIPS(self, item):
        MergeHIPS = [self.hipsBatchLocation,
                     "-r",
                     "MergeHIPS",
                     "--tide",
                     self.kwargs['TideSource'],
                     "--heave-source",
                     self.kwargs['HeaveSource']]
        MergeHIPS.append(item)
        print MergeHIPS
        self.runCommand(MergeHIPS)
        
    def computeHIPSTPU(self, item):
        ComputeHIPSTPU = [self.hipsBatchLocation,
                          "-r",
                          "ComputeHIPSTPU",
                          "--tide-measured",
                          self.kwargs['TideMeasured'] + 'm',
                          "--sv-measured",
                          self.kwargs['SVMeasured'] + 'm/s',
                          "--sv-surface",
                          self.kwargs['SVSurface'] + 'm/s',
                          "--source-navigation",
                          self.kwargs['TPUSource'],
                          "--source-sonar",
                          self.kwargs['TPUSource'],
                          "--source-gyro",
                          self.kwargs['TPUSource'],
                          "--source-pitch",
                          self.kwargs['TPUSource'],
                          "--source-roll",
                          self.kwargs['TPUSource'],
                          "--source-heave",
                          self.kwargs['TPUHeaveSource'],
                          "--source-tide",
                          self.kwargs['TPUTideSource']]
        ComputeHIPSTPU.append(item)
        print ComputeHIPSTPU
        self.runCommand(ComputeHIPSTPU)
        
    def exportPoints(self, item):
        ExportPoints = [self.hipsBatchLocation,
                       "-r",
                       "ExportPoints",
                       "--output-format",
                       "CSAR",
                       "--include-band",
                       "Vessel",
                       "--include-band",
                       "Day",
                       "--include-band",
                       "Line",
                       "--include-band",
                       "Depth",
                       "--include-band",
                       "Time",
                       "--include-band",
                       "Depth TPU",
                       "--include-band",
                       "Position TPU",
                       "--include-band",
                       "Beam",
                       "--include-band",
                       "Profile",
                       "--include-band",
                       "Tide",
                       "--include-band",
                       "Project"]
        if not os.path.isdir(os.path.dirname(self.invPointExport)):
            os.makedirs(os.path.dirname(self.invPointExport))
        ExportPoints.append(item)
        ExportPoints.append(self.invPointExport)
        print ExportPoints
        self.runCommand(ExportPoints)            
        
    def processHIPS(self):
        while not self.processQueue.empty():
            item = self.processQueue.get()
            if 'ImportTideToHIPS' in self.args:
                self.importTideToHIPS(item)
            if 'ImportHIPSFromAuxiliary' in self.args:  # 000
                self.importHIPSFromAuxiliary(item)
            if 'ComputeHIPSGPSTide' in self.args:   # elipsoid
                self.computeHIPSGPSTide(item)
            if 'FilterHIPSAttitude' in self.args:   # flags L1 points giving us L2
                self.filterHIPSAttitude(item)
            if 'SoundVelocityCorrectHIPS' in self.args: 
                self.soundVelocityCorrectHIPS(item)
            if 'MergeHIPS' in self.args:  # CARIS merge
                self.mergeHIPS(item)
            if 'ComputeHIPSTPU' in self.args:   # uncerainity
                self.computeHIPSTPU(item)
            if 'ExportPoints' in self.args:    # L1/L2 point cloud 
                self.exportPoints(item)
            
    def runCommand(self, cmd):
        try:
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)#, env=self.env)
            output, error = p.communicate()
            if output:
                self.dataSignal.emit(output)
            if error:
                self.errorSignal.emit(error)
        except OSError as e:
            self.errorSignal.emit(str(e.errno))
            self.errorSignal.emit(e.strerror)
            self.errorSignal.emit(str(e.filename))
        except:
            self.errorSignal.emit(sys.exc_info()[0])
                
        #processes = (subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, env=self.env)
        #             for cmd in self.importCommands)
        #running_processes = list(islice(processes, 1))
        #while running_processes:
        #    for i, process in enumerate(running_processes):
        #        process.wait()
        #        if process.poll() is not None:
        #            output, error = process.communicate()
        #            if output:
        #                self.dataSignal.emit(output)
        #            if error:
        #                self.errorSignal.emit(error)
        #            running_processes[i] = next(processes, None)
        #            if running_processes[i] is None:
        #                del running_processes[i]
        #            break