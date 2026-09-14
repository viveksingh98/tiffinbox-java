import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

void main() throws Exception {
    Path dir = Files.createTempDirectory(Path.of("."), "tiffinbox-silent-");

    // 1. a BufferedWriter that is never closed, so never flushed
    Path lost = dir.resolve("lost.csv");
    var out = new BufferedWriter(
                  new OutputStreamWriter(
                      new FileOutputStream(lost.toFile()), StandardCharsets.UTF_8));
    out.write("Ravi,2,120,VEG");
    IO.println("14 chars written, never closed -> " + Files.size(lost) + " bytes on disk, no exception");

    // 2. UTF-16 bytes read with a charset that cannot fail
    Path menu = dir.resolve("menu.txt");
    Files.writeString(menu, "TiffinBox menu: VEG\n", StandardCharsets.UTF_16);
    String iso = Files.readString(menu, StandardCharsets.ISO_8859_1).strip();
    IO.println("20 chars written, read as ISO-8859-1 -> " + iso.length() + " chars back, no exception");
    IO.println("what you got:   " + iso.replace((char) 0, '.'));

    // 3. the exception try-with-resources keeps — and the one a finally throws away
    try { handWritten(); }
    catch (Exception e) { IO.println("hand-written finally  -> " + e); }
    try { tryWithResources(); }
    catch (Exception e) {
        IO.println("try-with-resources    -> " + e);
        IO.println("  suppressed[0]:         " + e.getSuppressed()[0]);
    }

    Files.delete(lost);
    Files.delete(menu);
    Files.delete(dir);
}

/// A resource whose close() throws while the body is already throwing.
static class Flaky implements AutoCloseable {
    @Override public void close() { throw new IllegalStateException("close() failed too"); }
}

static void handWritten() throws Exception {
    Flaky f = new Flaky();
    try { throw new java.io.IOException("the disk is full"); }   // what you care about
    finally { f.close(); }                                       // ...silently replaced
}

static void tryWithResources() throws Exception {
    try (Flaky f = new Flaky()) { throw new java.io.IOException("the disk is full"); }
}
