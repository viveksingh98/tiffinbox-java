// The same two dependencies as pom.xml next door, declared in the same order.
// Maven and Gradle do not agree about what the answer is. That disagreement is the lesson.

plugins { java }

repositories { mavenCentral() }

dependencies {
    implementation("com.fasterxml.jackson.core:jackson-databind:2.22.2")  // pulls jackson-core 2.22.2
    implementation("com.fasterxml.jackson.core:jackson-core:2.13.5")      // and here is an older one, declared directly
}

tasks.withType<JavaCompile>().configureEach { options.release = 25 }
