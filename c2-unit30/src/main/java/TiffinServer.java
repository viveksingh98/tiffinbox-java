import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.Executors;

public class TiffinServer {
    static final int PORT = 8345;
    static final ObjectMapper MAPPER = new ObjectMapper();
    static final List<Customer> BOOK = List.of(
            new Customer("Ravi",  2, 120, true),
            new Customer("Meera", 1, 150, true),
            new Customer("Sunil", 3, 100, false),
            new Customer("Priya", 1, 120, true));

    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", PORT), 0);
        server.setExecutor(Executors.newVirtualThreadPerTaskExecutor());
        server.createContext("/customers", TiffinServer::customers);
        server.start();
        System.out.println("TiffinBox answering HTTP on " + PORT);
    }

    static void customers(HttpExchange ex) throws IOException {
        String tail = ex.getRequestURI().getPath().substring("/customers".length());
        String name = tail.startsWith("/") ? tail.substring(1) : "";
        if (name.isEmpty()) { send(ex, 200, BOOK); return; }
        Optional<Customer> hit = BOOK.stream().filter(c -> c.name().equalsIgnoreCase(name)).findFirst();
        if (hit.isPresent()) send(ex, 200, hit.get());
        else                 send(ex, 404, new ApiError("no such customer", name));
    }

    static void send(HttpExchange ex, int status, Object body) throws IOException {
        byte[] json = MAPPER.writeValueAsBytes(body);
        ex.getResponseHeaders().set("Content-Type", "application/json; charset=utf-8");
        ex.sendResponseHeaders(status, json.length);
        try (var out = ex.getResponseBody()) { out.write(json); }
        String req = ex.getRequestMethod() + " " + ex.getRequestURI().getPath();
        System.out.printf("  %-22s -> %d  virtual=%b  %s%n",
                req, status, Thread.currentThread().isVirtual(), Thread.currentThread());
    }
}
