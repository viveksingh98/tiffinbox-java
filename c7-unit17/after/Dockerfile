# TiffinBox's image. Maven builds the jar on your machine first; this file only packs it:
#   mvn -B package
#   docker build -t tiffinbox-docker:1.0.0 .
# Two stages: Boot's reference documentation's recipe, on the official Temurin 25 runtime image.

# Stage one: the jar goes in, and Boot's extract tool splits it into its four layers, inside the build.
FROM eclipse-temurin:25-jre AS builder
WORKDIR /builder
COPY tiffinbox-web/target/tiffinbox-web-1.0.0.jar application.jar
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

# Stage two: the image that runs. One COPY per layer, the layer that changes least first.
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=builder /builder/extracted/dependencies/ ./
COPY --from=builder /builder/extracted/spring-boot-loader/ ./
COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
COPY --from=builder /builder/extracted/application/ ./
# In a container, 127.0.0.1 is the container's own address: listen on every address the container has, and publish
# the port on the host's 127.0.0.1 alone (docker run -p 127.0.0.1:<port>:18425).
ENV TIFFINBOX_ADDRESS=0.0.0.0
# The base image runs as root. The user ubuntu (uid 1000) is already in it.
USER ubuntu
# Exec form - a JSON list, no shell: java is process 1, so docker stop's SIGTERM reaches it, and arguments after the
# image name reach TiffinBox. The shell form (ENTRYPOINT java -jar application.jar) loses both.
ENTRYPOINT ["java", "-jar", "application.jar"]
