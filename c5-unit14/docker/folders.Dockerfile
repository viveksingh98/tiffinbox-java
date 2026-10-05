# The same four layers, extracted on the Mac - in the context, by Boot's extract tool, before the build - and copied in as
# folders. Its context: a folder that holds extracted/ and nothing else.
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY extracted/dependencies/ ./
COPY extracted/spring-boot-loader/ ./
COPY extracted/snapshot-dependencies/ ./
COPY extracted/application/ ./
ENTRYPOINT ["java", "-jar", "application.jar"]
