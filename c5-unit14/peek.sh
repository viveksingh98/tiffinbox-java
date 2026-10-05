#!/bin/sh
# peek.sh IMAGE: what TiffinBoxServer's listening line says inside IMAGE - read from the image's own files, never by running
# it. A container is created (never started), /app/application.jar is copied out of it, and the container is removed.
set -e
n=tiffinbox-layers-peek
t=$(mktemp)
docker rm -f "$n" > /dev/null 2>&1 || true
docker create --name "$n" "$1" > /dev/null
docker cp -q "$n":/app/application.jar "$t"
docker rm "$n" > /dev/null
unzip -p "$t" com/tiffinbox/web/TiffinBoxServer.class | LC_ALL=C grep -aoE 'TiffinBox listening [a-z]+' || echo "(no listening line)"
rm -f "$t"
