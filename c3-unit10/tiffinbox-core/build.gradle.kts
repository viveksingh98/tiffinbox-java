plugins { `java-library` }

group = "com.tiffinbox"
version = "1.0.0"

repositories { mavenCentral() }

dependencies { api(libs.h2) }

tasks.withType<JavaCompile>().configureEach {
    options.release = 25
    options.encoding = "UTF-8"
}
