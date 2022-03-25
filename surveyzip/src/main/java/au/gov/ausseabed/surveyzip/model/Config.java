package au.gov.ausseabed.surveyzip.model;

import java.io.IOException;
import java.io.InputStream;
import java.util.Optional;
import java.util.Properties;

public class Config {
    private static final String outputBucket;
    private static final String outputPrefix;

    static {
        try (InputStream inputStream = Config.class.getClassLoader().getResourceAsStream("application.properties")) {
            Properties properties = new Properties();
            properties.load(inputStream);

            outputBucket = Optional.ofNullable(System.getenv("OUTPUT_BUCKET")).orElse(properties.getProperty("output.bucket"));
            outputPrefix = Optional.ofNullable(System.getenv("OUTPUT_PREFIX")).orElse(properties.getProperty("output.prefix"));
        } catch (IOException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static String getOutputBucket() {
        return outputBucket;
    }

    public static String getOutputPrefix() {
        return outputPrefix;
    }
}
