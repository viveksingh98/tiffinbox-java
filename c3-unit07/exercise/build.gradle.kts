plugins { java }

group = "com.tiffinbox"
version = "1.0.0"

dependencies {
    implementation("com.h2database:h2:2.5.250")
}

tasks.withType<JavaCompile>().configureEach {
    options.release = 25
    options.encoding = "UTF-8"
}
