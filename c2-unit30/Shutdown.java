import com.sun.net.httpserver.HttpServer;
import java.net.InetAddress;
import java.net.InetSocketAddress;

/// System.exit does not run finally blocks. A shutdown hook is the replacement.
/// Run: java Shutdown.java       (compact source file, binds 127.0.0.1:8345)
void main() throws Exception {
    HttpServer server = HttpServer.create(
            new InetSocketAddress(InetAddress.getLoopbackAddress(), 8345), 0);
    server.start();
    IO.println("server up on 8345");

    Runtime.getRuntime().addShutdownHook(new Thread(() -> {
        IO.println("  hook: stop(2) — finish what is in flight, then release the port");
        server.stop(2);
        IO.println("  hook: 8345 released");
    }));

    try {
        IO.println("calling System.exit(0) ...");
        System.exit(0);
    } finally {
        IO.println("  finally: you will never see this line");
    }
}
