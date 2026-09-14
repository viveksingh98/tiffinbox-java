import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;

/// Read ONE 50 MB file four ways, doing the SAME work each time: add up every byte.
/// The four checksums are identical, so the only thing that differs is the cost.
/// Timings move run to run and machine to machine — the RATIO is the lesson.
static final int SIZE = 50 * 1024 * 1024;          // 52,428,800 bytes exactly

void main() throws Exception {
    Path dir = Files.createTempDirectory(Path.of("."), "tiffinbox-50mb-");
    Path big = dir.resolve("orders.log");
    byte[] line = "Meera,1,150,VEG\n".getBytes();   // 16 bytes, divides 50 MB exactly
    try (var out = new BufferedOutputStream(Files.newOutputStream(big), 1 << 16)) {
        for (int written = 0; written < SIZE; written += line.length) out.write(line);
    }
    IO.println("file: " + Files.size(big) + " bytes");

    long t0 = System.nanoTime();
    long sum = 0;
    try (var in = new FileInputStream(big.toFile())) {
        int b;
        while ((b = in.read()) != -1) sum += b;              // one read call per byte
    }
    long unbuffered = report("FileInputStream, one byte at a time", t0, sum);

    t0 = System.nanoTime();
    sum = 0;
    try (var in = new BufferedInputStream(new FileInputStream(big.toFile()))) {
        int b;
        while ((b = in.read()) != -1) sum += b;              // same loop, 8 KB buffer
    }
    long buffered = report("BufferedInputStream, same loop     ", t0, sum);

    t0 = System.nanoTime();
    sum = 0;
    try (FileChannel ch = FileChannel.open(big, StandardOpenOption.READ)) {
        ByteBuffer buf = ByteBuffer.allocate(64 * 1024);
        while (ch.read(buf) != -1) {
            buf.flip();
            while (buf.hasRemaining()) sum += buf.get() & 0xFF;
            buf.clear();
        }
    }
    report("FileChannel + 64 KB ByteBuffer     ", t0, sum);

    t0 = System.nanoTime();
    sum = 0;
    try (FileChannel ch = FileChannel.open(big, StandardOpenOption.READ)) {
        MappedByteBuffer map = ch.map(FileChannel.MapMode.READ_ONLY, 0, ch.size());
        while (map.hasRemaining()) sum += map.get() & 0xFF;  // no read call at all
    }
    report("memory-mapped (MappedByteBuffer)   ", t0, sum);

    IO.println("unbuffered / buffered = about " + (unbuffered / buffered) + "x  (yours will differ)");
    Files.delete(big);
    Files.delete(dir);
}

long report(String label, long t0, long sum) {
    long ms = (System.nanoTime() - t0) / 1_000_000;
    IO.println("%s  %7d ms   checksum %d".formatted(label, ms, sum));
    return Math.max(ms, 1);
}
