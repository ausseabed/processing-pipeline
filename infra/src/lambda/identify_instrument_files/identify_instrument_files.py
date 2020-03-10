import json
import argparse
import re
from s3io import S3IO

def lambda_handler(event, context):
    print("Running the envent handler")

    print (event)
    print (context, flush=True)

    bucket_name=re.sub("/.*", "",event["src-instrument-location"].replace("s3://",""))
    instrument_input_folder=event["src-instrument-location"].replace("s3://{}/".format(bucket_name),"")

    print (bucket_name)
    print (instrument_input_folder)

    s3_L0 = S3IO(bucket_name)
    file_list = [ long_file.replace(instrument_input_folder,"").replace(event["pattern"],"") \
         for long_file in \
        s3_L0.list_keys(prefix=instrument_input_folder,pattern="*{}".format(event["pattern"]))]

    start = 0
    end = 1
    if ("start" in event):
        start=int(event["start"])
        
    if ("end" in event):
        end=int(event["end"])

    file_list = file_list[start:end] ## TODO Currently limited to ten to avoid input over capacity

    print (" ".join(file_list), flush=True)
    input_instructions = {"instrument-files":{ \
        "coverage-file":event["coverage-file"], \
        "instrument-file":[{\
        "s3_src_instrument":"{}{}{}".format(event["src-instrument-location"],name,event["pattern"]), \
        "s3_dest_las":"{}{}{}".format(event["src-las-location"],name,".las"), \
        "s3_dest_shp":{\
            "Name":"INPUT_FILES_{}".format(index),\
                "Value":"{}{}{}".format(event["src-shp-location"],name,".shp") \
                    }} \
            for (index,name) in zip(range(len(file_list)),file_list)]}}

    json_str = json.dumps(input_instructions, sort_keys=True, indent=4)
    print(json_str)

    output={}
    output["output"]=json_str
    return {
        'statusCode': 200,
        'body': input_instructions
    }


if __name__ == "__main__":
    print("Starting")
    event={}
    context={}
    event["src-instrument-location"]="s3://ausseabed-public-bathymetry/L0/20fcc1c2-67c3-4d21-a0b2-5e9d16613211/Multibeam/"
    #event["src-instrument-location"]="s3://bathymetry-survey-288871573946-1/Rawdata/"
    event["src-las-location"]="s3://bathymetry-survey-288871573946/L0Coverage/"
    event["src-shp-location"]="s3://bathymetry-survey-288871573946/L0Coverage/"
    event["pattern"]=".all"
    event["coverage-file"]="..."
    event["start"]=111
    event["end"]=111
    lambda_handler(event, context)

