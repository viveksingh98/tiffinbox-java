import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

/** Counts every write call that actually reaches the file. */
static class Counter extends OutputStream {
    private final OutputStream sink;
    int calls;
    Counter(OutputStream sink) { this.sink = sink; }
    @Override public void write(int b) throws java.io.IOException { calls++; sink.write(b); }
    @Override public void write(byte[] b, int off, int len) throws java.io.IOException {
        calls++; sink.write(b, off, len);
    }
    @Override public void close() throws java.io.IOException { sink.close(); }
}

static final String CSV = """
        name,mealsPerDay,pricePerMeal,mealType
        Ravi,2,120,VEG
        Meera,1,150,VEG
        Sunil,3,100,NON_VEG
        Priya,1,120,VEG
        """;

void main() throws Exception {
    Path dir = Files.createTempDirectory(Path.of("."), "tiffinbox-count-");
    byte[] bytes = CSV.getBytes(StandardCharsets.UTF_8);
    IO.println("payload: " + bytes.length + " bytes / " + CSV.length() + " chars");

    // 1. raw FileOutputStream, one byte at a time
    Counter c1 = new Counter(new FileOutputStream(dir.resolve("a").toFile()));
    try (c1) { for (byte b : bytes) c1.write(b); }
    IO.println("FileOutputStream, byte at a time        -> " + plural(c1.calls));

    // 2. the same loop, with a BufferedOutputStream in front
    Counter c2 = new Counter(new FileOutputStream(dir.resolve("b").toFile()));
    try (var buf = new BufferedOutputStream(c2)) { for (byte b : bytes) buf.write(b); }
    IO.println("BufferedOutputStream, byte at a time    -> " + plural(c2.calls));

    // 3. OutputStreamWriter alone: its encoder already holds 8192 bytes
    Counter c3 = new Counter(new FileOutputStream(dir.resolve("c").toFile()));
    try (var w = new OutputStreamWriter(c3, StandardCharsets.UTF_8)) {
        for (String line : CSV.split("\n")) { w.write(line); w.write("\n"); }
    }
    IO.println("OutputStreamWriter, line at a time      -> " + plural(c3.calls));

    // 4. the full chain from Slide 2
    Counter c4 = new Counter(new FileOutputStream(dir.resolve("d").toFile()));
    try (var w = new BufferedWriter(new OutputStreamWriter(c4, StandardCharsets.UTF_8))) {
        for (String line : CSV.split("\n")) { w.write(line); w.newLine(); }
    }
    IO.println("BufferedWriter over it, line at a time  -> " + plural(c4.calls));

    for (String n : new String[] {"a", "b", "c", "d"}) Files.delete(dir.resolve(n));
    Files.delete(dir);
}

static String plural(int n) { return n + (n == 1 ? " write call" : " write calls"); }
