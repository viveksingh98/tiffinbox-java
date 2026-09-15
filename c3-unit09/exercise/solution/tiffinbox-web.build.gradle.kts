plugins { java }

group = "com.tiffinbox"
version = "1.0.0"

repositories { mavenCentral() }

dependencies {
    implementation(project(":tiffinbox-core"))
    // HealthCheck.java imports org.h2.jdbcx.JdbcDataSource, so this module uses H2 - so
    // this module declares H2. The other fix (turning core's line into `api`) would make it
    // compile too, and it would be the wrong fix: it makes H2 part of core's public surface
    // for every consumer, forever, because one class here needed it.
    implementation(libs.h2)
}

tasks.withType<JavaCompile>().configureEach { options.release = 25; options.encoding = "UTF-8" }
