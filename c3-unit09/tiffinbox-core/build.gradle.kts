plugins {
    `java-library`          // NOT `java`: only java-library gives you the `api` configuration
}

group = "com.tiffinbox"
version = "1.0.0"

repositories { mavenCentral() }

dependencies {
    // `api` says: everyone who depends on tiffinbox-core also compiles against H2.
    // `implementation` would say: H2 is mine, at run time only, and nobody else sees it.
    // One word, and it decides what the module next door is allowed to import.
    api(libs.h2)
}

tasks.withType<JavaCompile>().configureEach {
    options.release = 25
    options.encoding = "UTF-8"
}
