package au.gov.ausseabed.surveyzip.model;

import java.util.List;

public class SurveyZipFile {
    public static final String MANIFEST_SUFFIX = ".manifest";

    private int surveyId;
    private String filename;
    private List<String> cogs;

    public int getSurveyId() {
        return surveyId;
    }

    public void setSurveyId(int surveyId) {
        this.surveyId = surveyId;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getManifestFilename() {
        return filename + MANIFEST_SUFFIX;
    }

    public List<String> getCogs() {
        return cogs;
    }

    public void setCogs(List<String> cogs) {
        this.cogs = cogs;
    }

    @Override
    public String toString() {
        return "SurveyZipFile{" +
                "surveyId=" + surveyId +
                ", filename='" + filename + '\'' +
                ", cogs=" + cogs +
                '}';
    }
}
