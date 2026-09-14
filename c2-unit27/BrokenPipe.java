import java.io.*;
import java.net.*;
import java.util.concurrent.CountDownLatch;
import static java.nio.charset.StandardCharsets.UTF_8;

/// The failure that fills production logs: the client vanishes MID-REPLY.
/// setSoLinger(true, 0) makes close() send a TCP reset instead of a polite FIN,
/// which is exactly what a killed process or a yanked cable looks like.
/// A CountDownLatch gates it, so there is no Thread.sleep anywhere.
static final int PORT = 8123;

void main() throws Exception {
    var clientGone = new CountDownLatch(1);
    try (ServerSocket server = new ServerSocket(PORT, 0,
            InetAddress.getLoopbackAddress())) {

        Thread.ofVirtual().start(() -> {                  // Ravi's phone app
            try (Socket client = new Socket(InetAddress.getLoopbackAddress(), PORT)) {
                client.setSoLinger(true, 0);              // close() -> RST, not FIN
                client.getOutputStream().write("ORDER Ravi 2\n".getBytes(UTF_8));
                client.getOutputStream().flush();
                client.getInputStream().read();           // read one byte of the reply
            } catch (IOException ignored) { }             // then die mid-reply
            clientGone.countDown();
        });

        try (Socket socket = server.accept()) {
            OutputStream raw = socket.getOutputStream();
            raw.write("OK Ravi 7200\n".getBytes(UTF_8));  // this one lands
            raw.flush();
            IO.println("first reply sent, client still connected");
            clientGone.await();                           // the gate, not a sleep
            IO.println("client is gone; the server keeps writing ...");
            try {
                for (int i = 0; i < 100_000; i++) raw.write("OK Ravi 7200\n".getBytes(UTF_8));
                IO.println("no error at all — nothing noticed");
            } catch (IOException e) {
                IO.println("caught: " + e);
            }
        }
    }
}
