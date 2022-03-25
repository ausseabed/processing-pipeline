FROM amazoncorretto:11.0.14-alpine3.12

RUN mkdir /surveyzip
RUN addgroup -S surveyzip
RUN adduser -S surveyzip -G surveyzip
RUN chown surveyzip:surveyzip /surveyzip

USER surveyzip
WORKDIR /surveyzip

ADD target/surveyzip.jar .

ENTRYPOINT ["java", "-jar", "surveyzip.jar"]
