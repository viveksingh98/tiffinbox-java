# What a build context holds: a Dockerfile that copies the whole folder - COPY . - into one image layer, /ctx.
# Build it on a folder, then list what arrived: docker run --rm --entrypoint ls <image> -A /ctx
# Not TiffinBox's Dockerfile (that one copies one jar): the receipts build this to see the context the builder received.
FROM eclipse-temurin:25-jre
COPY . /ctx
