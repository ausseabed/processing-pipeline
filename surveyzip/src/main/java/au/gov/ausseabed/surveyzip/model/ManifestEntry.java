package au.gov.ausseabed.surveyzip.model;

public class ManifestEntry {
    private final String location;
    private final String eTag;

    public ManifestEntry(String location, String eTag) {
        this.location = location;
        this.eTag = eTag;
    }

    public String getLocation() {
        return location;
    }

    public String geteTag() {
        return eTag;
    }

    @Override
    public String toString() {
        return "ManifestEntry{" +
                "location='" + location + '\'' +
                ", eTag='" + eTag + '\'' +
                '}';
    }
}
