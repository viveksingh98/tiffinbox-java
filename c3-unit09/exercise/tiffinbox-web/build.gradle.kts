plugins { java }

group = "com.tiffinbox"
version = "1.0.0"

repositories { mavenCentral() }

dependencies {
    implementation(project(":tiffinbox-core"))
}

tasks.withType<JavaCompile>().configureEach { options.release = 25; options.encoding = "UTF-8" }
