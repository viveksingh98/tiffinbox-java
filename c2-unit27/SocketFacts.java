import java.net.*;
import java.util.concurrent.CountDownLatch;

void main() throws Exception {
    try (ServerSocket server = new ServerSocket(8123, 0,
            InetAddress.getLoopbackAddress())) {    // loopback ONLY
        Socket a  = new Socket("localhost", 8123);  // two clients,
        Socket sa = server.accept();                // one port
        Socket b  = new Socket("localhost", 8123);
        Socket sb = server.accept();
        IO.println("ServerSocket is a Socket?    "
                 + Socket.class.isAssignableFrom(ServerSocket.class));
        IO.println("one ServerSocket on port     " + server.getLocalPort());
        IO.println("accept() gave two Sockets    " + (sa != sb));
        IO.println("server port on both          "
                 + sa.getLocalPort() + " and " + sb.getLocalPort());
        IO.println("their client ports differ    "
                 + (sa.getPort() != sb.getPort()));
        a.close(); b.close(); sa.close(); sb.close();

        var inAccept = new CountDownLatch(1);
        Thread t = new Thread(() -> {
            try { inAccept.countDown(); server.accept(); }
            catch (Exception e) {
                IO.println("after close(), accept() threw:\n  " + e);
            }
        });
        t.start();
        inAccept.await();
        t.interrupt();
        t.join(300);
        IO.println("after interrupt(): " + t.getState()
                 + ", interrupted flag " + t.isInterrupted());
        server.close();                 // THIS is the off switch
        t.join();
    }
}
