/// ApiCall.java — one synchronous HTTP call, against a LOCAL server only.
/// Start the server first (it ships with the JDK):
///     jwebserver -p 8234 -d "$PWD/www"
/// Then, in a second terminal:
///     java ApiCall.java

import module java.net.http;   // java.base is implicit; HttpClient is NOT in java.base

static final String BASE = "http://localhost:8234/";

void main() throws Exception {
    // ONE client: it owns the connection pool, the HTTP/2 sessions and an executor.
    try (HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(2))          // time to GET a connection
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build()) {

        // MANY requests: immutable, cheap, one per call.
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE + "customers.json"))
                .timeout(Duration.ofSeconds(5))             // time for the WHOLE exchange
                .header("Accept", "application/json")
                .GET()
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        IO.println("status:        " + response.statusCode());
        IO.println("http version:  " + response.version());
        IO.println("content-type:  " + response.headers().firstValue("content-type").orElse("(none)"));
        IO.println("body bytes:    " + response.body().getBytes(StandardCharsets.UTF_8).length);
        IO.println("first line:    " + response.body().lines().skip(1).findFirst().orElse(""));

        // A file that does not exist. No exception is thrown — a response arrived.
        HttpRequest missing = HttpRequest.newBuilder()
                .uri(URI.create(BASE + "week-9.json"))
                .timeout(Duration.ofSeconds(5))
                .GET()
                .build();
        HttpResponse<String> gone = client.send(missing, HttpResponse.BodyHandlers.ofString());
        IO.println("week-9.json:   " + gone.statusCode() + "  <- check the status, always");
    }
}
