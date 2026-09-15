plugins { java }

group = "com.tiffinbox"
version = "1.0.0"

// Maven's Super POM hands every project a <repositories> block with Central in it, which
// is why no pom.xml in this course ever names a repository. Gradle hands you nothing:
// if a dependency comes from outside the project, you say where from.
repositories {
    mavenCentral()
}

dependencies {
    implementation("com.h2database:h2:2.5.250")
}

tasks.withType<JavaCompile>().configureEach {
    options.release = 25
    options.encoding = "UTF-8"
}
