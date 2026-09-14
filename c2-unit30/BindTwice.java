import com.sun.net.httpserver.HttpServer;
import java.net.BindException;
import java.net.InetSocketAddress;

/// The most common first-run failure in server work, in six honest lines.
/// Run: java BindTwice.java      (compact source file, no dependencies)
void main() throws Exception {
    HttpServer first = HttpServer.create(new InetSocketAddress("127.0.0.1", 8345), 0);
    first.start();
    IO.println("first server bound to 8345");
    try {
        IO.println("starting a second one on the same port ...");
        HttpServer second = HttpServer.create(new InetSocketAddress("127.0.0.1", 8345), 0);
        second.start();                       // never reached: create() already threw
        IO.println("this line never prints");
    } catch (BindException e) {
        IO.println("  java.net.BindException: " + e.getMessage());
    } finally {
        first.stop(0);                        // or the JVM hangs
        IO.println("first server stopped, 8345 released");
    }
}
