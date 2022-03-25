package au.gov.ausseabed.surveyzip.model;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;

public class COGFile {
    private String bucket;
    private String prefix;
    private String filename;

    public COGFile(String s3Uri) {
        try {
            URI uri = new URI(s3Uri);

            bucket = uri.getHost();
            prefix = uri.getPath().substring(1);
            filename = new File(prefix).getName();
        } catch (URISyntaxException e) {
            throw new RuntimeException(e);
        }
    }

    public String getBucket() {
        return bucket;
    }

    public String getPrefix() {
        return prefix;
    }

    public String getFilename() {
        return filename;
    }

    @Override
    public String toString() {
        return "BucketAndPrefix{" +
                "bucket='" + bucket + '\'' +
                ", prefix='" + prefix + '\'' +
                ", filename='" + filename + '\'' +
                '}';
    }
}
