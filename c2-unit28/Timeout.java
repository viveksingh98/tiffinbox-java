/// Timeout.java — a server that is UP and SLOW. No jwebserver, no internet, no flags.
/// Run:  java Timeout.java        (exits 1, on purpose)

import module java.net.http;

static final int PORT = 8456;

void main() throws Exception {
    try (var stalled = new ServerSocket(PORT, 0, InetAddress.getLoopbackAddress())) {  // loopback ONLY
        Thread.ofVirtual().start(() -> {                           // virtual => daemon
            try (Socket accepted = stalled.accept()) {             // handshake succeeds...
                Thread.sleep(Duration.ofMinutes(1));               // ...then it says nothing
            } catch (Exception ignored) { }
        });
        HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(2)).build();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + PORT + "/customers"))
                .timeout(Duration.ofMillis(500))                   // the whole exchange
                .GET()
                .build();
        IO.println("GET http://localhost:" + PORT + "/customers   timeout = 500 ms");
        client.send(request, HttpResponse.BodyHandlers.ofString());
    }
}
