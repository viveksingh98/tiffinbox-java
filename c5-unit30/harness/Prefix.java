import com.sun.net.httpserver.HttpServer;

import java.net.InetSocketAddress;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

/**
 * The harness's witness - the course's, never TiffinBox's: how the JDK's own HTTP server picks a context for a path. Three
 * contexts, created in this order - /c, /customers, /customersX - each answering with its own path; then five requests, each
 * printed with the context that answered. No TiffinBox class is on the class path: this is the rule TiffinBox's server inherits.
 * Run as a single source file: java harness/Prefix.java PORT (127.0.0.1 only).
 */
public class Prefix {
    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(args[0]);
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", port), 0);
        for (String c : new String[] {"/c", "/customers", "/customersX"}) {
            server.createContext(c, x -> {
                byte[] b = ("context " + x.getHttpContext().getPath()).getBytes(StandardCharsets.UTF_8);
                x.sendResponseHeaders(200, b.length);
                x.getResponseBody().write(b);
                x.close();
            });
        }
        server.start();
        try {
            System.out.println("harness: contexts created, in this order: /c, /customers, /customersX");
            HttpClient client = HttpClient.newHttpClient();
            for (String p : new String[] {"/customersXYZ", "/customers/", "/customers", "/cat", "/nowhere"}) {
                HttpResponse<String> r = client.send(HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + p)).build(),
                        HttpResponse.BodyHandlers.ofString());
                System.out.println("harness: " + p + " -> " + r.statusCode() + (r.statusCode() == 200 ? " " + r.body() : " (no context)"));
            }
        } finally {
            server.stop(0);
        }
    }
}
