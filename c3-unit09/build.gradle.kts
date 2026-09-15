// The root project builds nothing, exactly like the parent POM whose <packaging> is pom.
// It has no plugins and no sources; settings.gradle.kts is what makes it a build at all.
//
// (Do not try `plugins { java apply false }` here to "declare" it for the children.
//  Gradle 9.7.1 refuses: "Plugin 'org.gradle.java' is a core Gradle plugin, which is
//  already on the classpath. Requesting it with the 'apply false' option is a no-op.")
