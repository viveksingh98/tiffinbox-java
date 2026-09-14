import java.io.*;
import java.net.*;
import static java.nio.charset.StandardCharsets.UTF_8;

void main() throws Exception {
    String[] orders = { "ORDER Ravi 2", "ORDER Meera 1",
            "ORDER Sunil 3", "ORDER Priya 1", "CLOSE" };
    try (Socket socket = new Socket("localhost", 8123);
         var out = new PrintWriter(new OutputStreamWriter(
                 socket.getOutputStream(), UTF_8), true);
         var in  = new BufferedReader(new InputStreamReader(
                 socket.getInputStream(), UTF_8))) {
        IO.println("connected to "
                 + socket.getInetAddress().getHostAddress()
                 + ":" + socket.getPort());
        for (String order : orders) {
            out.println(order);      // the newline IS the boundary
            String reply = in.readLine();  // blocks till a newline
            IO.println("%-14s<-  %s".formatted(order, reply));
        }
    }
}
