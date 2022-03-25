package au.gov.ausseabed.surveyzip.model;

public class ManifestEntry {
    private final String filename;
    private final String eTag;

    public ManifestEntry(String filename, String eTag) {
        this.filename = filename;
        this.eTag = eTag;
    }

    public String getFilename() {
        return filename;
    }

    public String geteTag() {
        return eTag;
    }

    @Override
    public String toString() {
        return "ManifestEntry{" +
                "filename='" + filename + '\'' +
                ", eTag='" + eTag + '\'' +
                '}';
    }
}
