#!/bin/bash
# The flag is -am : "also make" the modules this one depends on.
# Run from c3-unit02/exercise/solution/ ; it steps up to the reactor root itself.
set -e
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd "$(dirname "$0")/../.."
mvn -B clean package -pl tiffinbox-kitchen -am -Dmaven.repo.local="$PWD/.m2-demo"
