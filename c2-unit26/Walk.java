import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Comparator;
import java.util.stream.Stream;

void main() throws IOException {
    Path root = Files.createTempDirectory(Path.of("."), "tiffinbox-walk-");
    Files.createDirectories(root.resolve("menus/2026-09"));
    Files.createDirectories(root.resolve("menus/archive"));
    Files.writeString(root.resolve("menus/2026-09/week-1.csv"), "Ravi,2,120,VEG\n");
    Files.writeString(root.resolve("menus/2026-09/week-2.csv"), "Meera,1,150,VEG\n");
    Files.writeString(root.resolve("menus/archive/2026-08.csv"), "Sunil,3,100,NON_VEG\nPriya,1,120,VEG\n");
    Files.writeString(root.resolve("menus/README.txt"), "menus live here\n");

    try (Stream<Path> all = Files.walk(root)) {
        IO.println("entries under the root: " + all.count());
    }

    long bytes = 0;
    try (Stream<Path> csv = Files.find(root, 10,
            (p, a) -> a.isRegularFile() && p.getFileName().toString().endsWith(".csv"))) {
        for (Path rel : csv.map(root::relativize).sorted().toList()) {
            IO.println("  found " + rel);
            bytes += Files.size(root.resolve(rel));
        }
    }
    IO.println("total bytes of menus:  " + bytes);

    Path week1 = root.resolve("menus/2026-09/week-1.csv");
    BasicFileAttributes a = Files.readAttributes(week1, BasicFileAttributes.class);
    IO.println(week1.getFileName() + "  regular=" + a.isRegularFile()
             + "  size=" + a.size() + "  dir=" + a.isDirectory());

    try (Stream<Path> all = Files.walk(root)) {
        all.sorted(Comparator.reverseOrder()).forEach(p -> {
            try { Files.delete(p); } catch (IOException e) { throw new UncheckedIOException(e); }
        });
    }
    IO.println("cleaned up:            " + Files.notExists(root));
}
