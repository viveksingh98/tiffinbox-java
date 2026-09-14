import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicInteger;

/// Why setExecutor matters: NO executor set, plus the two special content lengths.
/// Run: java NoExecutor.java   (Ctrl-C to stop it — it binds 127.0.0.1:8345)
static final AtomicInteger SEQ = new AtomicInteger();

void main() throws Exception {
    HttpServer s = HttpServer.create(new InetSocketAddress("127.0.0.1", 8345), 0);
    // deliberately NO setExecutor(...)
    s.createContext("/plain", ex -> {
        byte[] b = "{\"ok\":true}".getBytes(StandardCharsets.UTF_8);
        ex.getResponseHeaders().set("Content-Type", "application/json");
        ex.sendResponseHeaders(200, b.length);
        try (var o = ex.getResponseBody()) { o.write(b); }
        IO.println("  /plain   handler thread: " + Thread.currentThread());
        IO.println("  /plain   isVirtual()   : " + Thread.currentThread().isVirtual());
    });
    s.createContext("/zero", ex -> {
        byte[] b = "{\"ok\":true}".getBytes(StandardCharsets.UTF_8);
        ex.getResponseHeaders().set("Content-Type", "application/json");
        ex.sendResponseHeaders(200, 0);          // 0 = chunked
        try (var o = ex.getResponseBody()) { o.write(b); }
    });
    s.createContext("/none", ex -> {
        ex.sendResponseHeaders(204, -1);         // -1 = no body at all
        ex.close();
    });
    // A slow handler, so two curls at once can SHOW the queueing instead of asserting it.
    // The number is the arrival order, counted by the server, so the log reads the same every run.
    s.createContext("/slow", ex -> {
        int n = SEQ.incrementAndGet();
        IO.println("  enter #" + n + "  thread=" + Thread.currentThread().getName());
        try { Thread.sleep(1200); } catch (InterruptedException ignored) { }
        byte[] b = ("{\"handled\":" + n + "}").getBytes(StandardCharsets.UTF_8);
        ex.sendResponseHeaders(200, b.length);
        try (var o = ex.getResponseBody()) { o.write(b); }
        IO.println("  exit  #" + n);
    });
    s.start();
    IO.println("probe up on 8345");
    // No keep-alive trick needed: HttpServer's dispatcher thread is NOT a daemon,
    // so it holds the JVM open by itself. That is the fact slide 6 teaches.
}
