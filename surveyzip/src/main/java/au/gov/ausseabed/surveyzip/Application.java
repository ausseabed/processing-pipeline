package au.gov.ausseabed.surveyzip;

import alex.mojaki.s3upload.MultiPartOutputStream;
import alex.mojaki.s3upload.StreamTransferManager;
import au.gov.ausseabed.surveyzip.model.COGFile;
import au.gov.ausseabed.surveyzip.model.Config;
import au.gov.ausseabed.surveyzip.model.ManifestEntry;
import au.gov.ausseabed.surveyzip.model.SurveyZipFile;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.google.gson.Gson;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class Application {
    private static final Logger logger = LoggerFactory.getLogger(Application.class);
    private static final Gson gson = new Gson();
    private static final AmazonS3 s3Client = AmazonS3ClientBuilder.standard().withRegion(Regions.AP_SOUTHEAST_2).build();

    public static void main(String[] args) {
        SurveyZipFile surveyZipFile = gson.fromJson(args[0], SurveyZipFile.class);

        logger.info("Processing survey zip file request");
        logger.info("{}", surveyZipFile);

        logger.info("Creating zip file: s3://{}/{}", Config.getOutputBucket(), Config.getOutputPrefix() + surveyZipFile.getFilename());

        List<ManifestEntry> manifest = new ArrayList<>();
        StreamTransferManager transferManager = new StreamTransferManager(Config.getOutputBucket(), Config.getOutputPrefix() + surveyZipFile.getFilename(), s3Client);
        Map<String, Integer> counts = new HashMap<>();

        try (
                MultiPartOutputStream multiPartOutputStream = transferManager.getMultiPartOutputStreams().get(0);
                ZipOutputStream zipOutputStream = new ZipOutputStream(multiPartOutputStream)
        ) {
            for (String cogLocation : surveyZipFile.getCogs()) {
                COGFile cog = new COGFile(cogLocation);

                int count = counts.merge(cog.getFilename(), 1, Integer::sum);
                logger.info("Adding {} to zip file", cog.getFilename(count));

                S3Object object = s3Client.getObject(cog.getBucket(), cog.getPrefix());

                ZipEntry zipEntry = new ZipEntry(cog.getFilename(count));
                zipOutputStream.putNextEntry(zipEntry);

                S3ObjectInputStream stream = object.getObjectContent();

                byte[] bytes = new byte[1024];
                int length;
                while ((length = stream.read(bytes)) >= 0) {
                    zipOutputStream.write(bytes, 0, length);
                }
                stream.close();
                zipOutputStream.closeEntry();

                manifest.add(
                        new ManifestEntry(cogLocation, object.getObjectMetadata().getETag())
                );
            }

            ZipEntry zipEntry = new ZipEntry("metadata.txt");
            zipOutputStream.putNextEntry(zipEntry);
            byte[] bytes = surveyZipFile.getMetadata().getBytes();
            zipOutputStream.write(bytes, 0, bytes.length);
            zipOutputStream.closeEntry();
        } catch (Exception e) {
            transferManager.abort();
            logger.error("Error creating survey zip file", e);
        } finally {
            transferManager.complete();
        }

        logger.info("Writing manifest file: s3://{}/{}", Config.getOutputBucket(), Config.getOutputPrefix() + surveyZipFile.getManifestFilename());
        s3Client.putObject(Config.getOutputBucket(), Config.getOutputPrefix() + surveyZipFile.getManifestFilename(), gson.toJson(manifest));
    }
}
