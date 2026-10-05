# What a build context holds: a Dockerfile that copies the whole folder - COPY . - into one image layer, /tiffinbox-ctx.
# Build it on a folder, then list what arrived: docker run --rm --entrypoint ls <image> -A /tiffinbox-ctx
# Not TiffinBox's Dockerfile (that one copies one jar): the receipts build this to see the context the builder received.
# The target's name is this file's alone: BuildKit names the step's cache records after it ("COPY . /tiffinbox-ctx"), and
# the receipts remove those records - the folder's files, the token among them - with a prune filtered to that name
# (docker buildx prune -f --filter 'description~=tiffinbox-ctx').
FROM eclipse-temurin:25-jre
COPY . /tiffinbox-ctx
