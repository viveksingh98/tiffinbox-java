plugins { java }

group = "com.tiffinbox"
version = "1.0.0"

repositories { mavenCentral() }

dependencies {
    implementation(project(":tiffinbox-core"))
    implementation(libs.jackson.databind)
}

tasks.withType<JavaCompile>().configureEach {
    options.release = 25
    options.encoding = "UTF-8"
}

// The POM next door writes Main-Class and a lib/ Class-Path, and copies five jars into
// target/lib. These two blocks are the same two jobs, written the Gradle way.
tasks.jar {
    manifest {
        attributes(
            "Main-Class" to "com.tiffinbox.web.TiffinBoxServer",
            "Class-Path" to configurations.runtimeClasspath.get().files.joinToString(" ") { "lib/" + it.name }
        )
    }
}

val copyLibs = tasks.register<Copy>("copyLibs") {
    from(configurations.runtimeClasspath)
    into(layout.buildDirectory.dir("libs/lib"))
}

tasks.jar { dependsOn(copyLibs) }
