package au.gov.ausseabed.surveyzip.s3upload;

import alex.mojaki.s3upload.StreamTransferManager;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.InitiateMultipartUploadRequest;
import com.amazonaws.services.s3.model.PutObjectRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CustomStreamTransferManager extends StreamTransferManager {
    private static final Logger logger = LoggerFactory.getLogger(CustomStreamTransferManager.class);

    public CustomStreamTransferManager(String bucketName, String putKey, AmazonS3 s3Client) {
        super(bucketName, putKey, s3Client);
    }

    @Override
    public void customisePutEmptyObjectRequest(PutObjectRequest request) {
        logger.debug("Setting PutObject ACL to {}", CannedAccessControlList.BucketOwnerFullControl);
        request.setCannedAcl(CannedAccessControlList.BucketOwnerFullControl);
    }

    @Override
    public void customiseInitiateRequest(InitiateMultipartUploadRequest request) {
        logger.debug("Setting InitiateMultipartUploadRequest ACL to {}", CannedAccessControlList.BucketOwnerFullControl);
        request.setCannedACL(CannedAccessControlList.BucketOwnerFullControl);
    }
}
