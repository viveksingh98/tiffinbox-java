plugins { `java-library` }

group = "com.tiffinbox"
version = "1.0.0"

repositories { mavenCentral() }

dependencies {
    // Correct as it stands: H2 is this module's business, not the web module's.
    // Do not change this line.
    implementation(libs.h2)
}

tasks.withType<JavaCompile>().configureEach { options.release = 25; options.encoding = "UTF-8" }
