# The two-stage shape of Boot's reference documentation (4.1.1, "Dockerfiles") - its base image, its folder and its jar
# argument swapped for eclipse-temurin:25-jre, /app and the jar's own name. Its context: a folder holding that jar alone.
# Stage one copies the jar in and runs Boot's extract tool INSIDE the build.
FROM eclipse-temurin:25-jre AS builder
WORKDIR /builder
COPY tiffinbox-web-1.0.0.jar application.jar
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

# Stage two copies each layer folder: one COPY, one image layer.
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=builder /builder/extracted/dependencies/ ./
COPY --from=builder /builder/extracted/spring-boot-loader/ ./
COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
COPY --from=builder /builder/extracted/application/ ./
ENTRYPOINT ["java", "-jar", "application.jar"]
