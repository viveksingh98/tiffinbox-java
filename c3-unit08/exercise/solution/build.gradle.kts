// The fix: declare the output. Now Gradle has something to compare and can answer the
// question "is there anything left to do?" - which is the only way a task can be skipped.

abstract class Stamp : DefaultTask() {

    @get:Input
    abstract val text: Property<String>

    @get:OutputFile
    abstract val stampFile: RegularFileProperty

    @TaskAction
    fun go() {
        val out = stampFile.get().asFile
        out.parentFile.mkdirs()
        out.writeText(text.get() + "\n")
    }
}

tasks.register<Stamp>("stamp") {
    text = "tiffinbox"
    stampFile = layout.buildDirectory.file("stamp.txt")
}
