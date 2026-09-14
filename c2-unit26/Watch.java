import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.WatchEvent;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.util.concurrent.CountDownLatch;

import static java.nio.file.StandardWatchEventKinds.ENTRY_CREATE;
import static java.nio.file.StandardWatchEventKinds.ENTRY_DELETE;

void main() throws Exception {
    Path root  = Files.createTempDirectory(Path.of("."), "tiffinbox-watch-");
    Path menus = Files.createDirectories(root.resolve("menus"));
    Path week3 = menus.resolve("week-3.csv");
    var seenCreate = new CountDownLatch(1);

    try (WatchService watcher = FileSystems.getDefault().newWatchService()) {
        menus.register(watcher, ENTRY_CREATE, ENTRY_DELETE);
        IO.println("watching menus/ for new CSVs");

        Thread asha = Thread.ofVirtual().start(() -> {
            try {
                Files.writeString(week3, "Sunil,3,100,NON_VEG\n");
                seenCreate.await();
                Files.delete(week3);
            } catch (Exception e) { throw new RuntimeException(e); }
        });

        WatchKey key = watcher.take();
        for (WatchEvent<?> event : key.pollEvents())
            IO.println("  " + event.kind().name() + " : " + event.context());
        key.reset();
        seenCreate.countDown();

        key = watcher.take();
        for (WatchEvent<?> event : key.pollEvents())
            IO.println("  " + event.kind().name() + " : " + event.context());
        key.reset();
        asha.join();
    }

    Files.delete(menus);
    Files.delete(root);
    IO.println("watcher closed, directory removed");
}
