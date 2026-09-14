import java.io.*;
import java.net.*;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;
import static java.nio.charset.StandardCharsets.UTF_8;

record Customer(String name, int mealsPerDay, int pricePerMeal) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}
static final int PORT = 8123;
static final Map<String, Integer> PRICES = Map.of(
        "Ravi", 120, "Meera", 150, "Sunil", 100, "Priya", 120);

void main() throws Exception {
    var revenue = new AtomicInteger();
    var stop    = new CountDownLatch(1);
    try (ServerSocket server = new ServerSocket(PORT, 0,
            InetAddress.getLoopbackAddress())) {   // loopback ONLY
        IO.println("order line listening on " + PORT);
        Thread.ofVirtual().start(() -> {    // unblocks accept()
            try { stop.await(); server.close(); }
            catch (Exception ignored) { }
        });
        while (true) {
            Socket socket = server.accept();     // blocks
            IO.println("connection accepted -> one virtual thread");
            Thread.ofVirtual().start(
                    () -> handle(socket, revenue, stop));
        }
    } catch (SocketException closed) {   // accept() was closed
        IO.println("order line closed, revenue booked: "
                 + revenue.get());
    }
}

static void handle(Socket socket, AtomicInteger revenue,
                   CountDownLatch stop) {
    try (socket;
         var in  = new BufferedReader(new InputStreamReader(
                 socket.getInputStream(), UTF_8));
         var out = new PrintWriter(new OutputStreamWriter(
                 socket.getOutputStream(), UTF_8), true)) {
        String line;
        while ((line = in.readLine()) != null) {  // 1 request = 1 line
            String[] p = line.split(" ");
            if (p[0].equals("CLOSE")) {
                out.println("BYE"); stop.countDown(); return;
            }
            Integer price = PRICES.get(p.length == 3 ? p[1] : "");
            if (price == null) {
                out.println("ERR unknown order"); continue;
            }
            Customer c = new Customer(
                    p[1], Integer.parseInt(p[2]), price);
            revenue.addAndGet(c.monthlyBill());
            String reply = "OK " + c.name() + " " + c.monthlyBill();
            out.println(reply);            // auto-flush: on the wire
            IO.println("  " + line + "  -> " + reply + "  (virtual: "
                     + Thread.currentThread().isVirtual() + ")");
        }
    } catch (IOException e) {
        IO.println("  client dropped: " + e.getMessage());
    }
}
