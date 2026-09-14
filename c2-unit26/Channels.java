import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;

String marks(String label, ByteBuffer b) {
    return label + " pos=" + b.position() + " limit=" + b.limit() + " cap=" + b.capacity();
}

void main() throws Exception {
    Path dir = Files.createTempDirectory(Path.of("."), "tiffinbox-nio-");
    Path csv = dir.resolve("week-1.csv");
    Files.writeString(csv, "Ravi,2,120,VEG\nMeera,1,150,VEG\n");

    try (FileChannel ch = FileChannel.open(csv, StandardOpenOption.READ)) {
        ByteBuffer buf = ByteBuffer.allocate(64);
        IO.println(marks("empty  ", buf));

        int n = ch.read(buf);
        IO.println("read " + n + " bytes");
        IO.println(marks("filled ", buf));

        buf.flip();
        IO.println(marks("flipped", buf));

        String text = StandardCharsets.UTF_8.decode(buf).toString();
        IO.println("decoded: " + text.replace("\n", " | "));

        MappedByteBuffer map = ch.map(FileChannel.MapMode.READ_ONLY, 0, ch.size());
        int end = 0;
        while (end < map.limit() && map.get(end) != '\n') end++;
        // name the charset here too: a byte is not a char, not even for ASCII
        String firstLine = StandardCharsets.UTF_8.decode(map.slice(0, end)).toString();
        IO.println("mapped " + map.remaining() + " bytes, first line: " + firstLine);
    }

    Files.delete(csv);
    Files.delete(dir);
}
