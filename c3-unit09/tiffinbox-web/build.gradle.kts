plugins {
    java
    application
}

group = "com.tiffinbox"
version = "1.0.0"

repositories { mavenCentral() }

dependencies {
    // Two dependencies. H2 is not one of them - and HealthCheck.java imports an H2 class.
    implementation(project(":tiffinbox-core"))
    implementation(libs.jackson.databind)
}

application { mainClass = "com.tiffinbox.web.TiffinBoxServer" }

// Runs the /health probe on the module's own RUNTIME classpath - which contains H2
// either way. That is the second half of the lesson: `implementation` takes a library
// off the consumer's COMPILE classpath, and off it alone. `./gradlew :tiffinbox-web:dependencies
// --configuration runtimeClasspath` shows h2 still there after the flip.
tasks.register<JavaExec>("health") {
    group = "application"
    description = "Runs the /health probe against an in-memory database."
    mainClass = "com.tiffinbox.web.HealthCheck"
    classpath = sourceSets.main.get().runtimeClasspath
}

tasks.withType<JavaCompile>().configureEach {
    options.release = 25
    options.encoding = "UTF-8"
}
