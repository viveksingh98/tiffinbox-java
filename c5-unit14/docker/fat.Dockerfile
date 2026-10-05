# The fat-jar image: the whole jar, in one COPY. Its context: a folder that holds tiffinbox-web-1.0.0.jar and nothing else.
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY tiffinbox-web-1.0.0.jar application.jar
ENTRYPOINT ["java", "-jar", "application.jar"]
