// A one-task build. The task writes build/stamp.txt from a string you give it.
// Run it twice. It runs twice. Gradle will tell you exactly why if you ask with --info.

abstract class Stamp : DefaultTask() {

    @get:Input
    abstract val text: Property<String>

    // one line is missing here

    @TaskAction
    fun go() {
        val out = project.layout.buildDirectory.file("stamp.txt").get().asFile
        out.parentFile.mkdirs()
        out.writeText(text.get() + "\n")
    }
}

tasks.register<Stamp>("stamp") {
    text = "tiffinbox"
}
