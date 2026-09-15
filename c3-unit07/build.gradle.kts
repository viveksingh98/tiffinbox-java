// The whole build, in one file. Every line has a counterpart in pom.xml next door.

plugins {
    java                                  // <packaging>jar</packaging>: src/main/java, a jar, the lot
}

group = "com.tiffinbox"                   // <groupId>
version = "1.0.0"                         // <version>

repositories {
    mavenCentral()                        // the <repositories> block Maven's Super POM gave you for free
}

dependencies {
    implementation("com.h2database:h2:2.5.250")   // <dependency> - group:name:version on one line
}

tasks.withType<JavaCompile>().configureEach {
    options.release = 25                  // <maven.compiler.release>25</maven.compiler.release>
    options.encoding = "UTF-8"            // <project.build.sourceEncoding>UTF-8</...>
}
