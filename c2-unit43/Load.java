// Load.java — drive the TiffinBox server hard enough that there is something to watch.
// One virtual thread per request, a semaphore to cap how many are in flight at once.
// java Load.java <port> <requests> <inFlight>
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;

void main(String[] args) throws Exception {
    int port     = args.length > 0 ? Integer.parseInt(args[0]) : 18543;
    int requests = args.length > 1 ? Integer.parseInt(args[1]) : 6000;
    int inFlight = args.length > 2 ? Integer.parseInt(args[2]) : 200;

    var uri   = URI.create("http://127.0.0.1:" + port + "/dashboard");
    var http  = HttpClient.newHttpClient();
    var gate  = new Semaphore(inFlight);
    var ok    = new AtomicInteger();
    Set<String> bodies = ConcurrentHashMap.newKeySet();

    try (var pool = Executors.newVirtualThreadPerTaskExecutor()) {
        for (int i = 0; i < requests; i++) {
            gate.acquire();
            pool.submit(() -> {
                try {
                    var res = http.send(HttpRequest.newBuilder(uri).build(),
                                        HttpResponse.BodyHandlers.ofString());
                    if (res.statusCode() == 200) ok.incrementAndGet();
                    bodies.add(res.body());
                } catch (Exception e) {
                    IO.println("failed: " + e);
                } finally {
                    gate.release();
                }
            });
        }
    }
    IO.println("requests sent:   " + requests);
    IO.println("200 responses:   " + ok.get());
    IO.println("distinct bodies: " + bodies.size());
    for (String b : bodies) IO.println("body:            " + b);
}
