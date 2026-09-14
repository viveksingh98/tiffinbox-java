/// AsyncCalls.java — four calls in flight at once, against a LOCAL server only.
/// Start the server first (it ships with the JDK):
///     jwebserver -p 8234 -d "$PWD/www"
/// Then, in a second terminal:
///     java AsyncCalls.java

import module java.net.http;   // java.base is implicit; HttpClient is NOT in java.base

static final String BASE = "http://localhost:8234/";
static final List<String> FILES = List.of("ravi.json", "meera.json", "sunil.json", "priya.json");

void main() throws Exception {
    try (HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(2))
            .build()) {

        List<HttpRequest> requests = FILES.stream()
                .map(f -> HttpRequest.newBuilder()
                        .uri(URI.create(BASE + f))
                        .timeout(Duration.ofSeconds(5))
                        .GET()
                        .build())
                .toList();

        List<CompletableFuture<HttpResponse<String>>> calls = requests.stream()
                .map(r -> client.sendAsync(r, HttpResponse.BodyHandlers.ofString()))
                .toList();

        // ONE blocking point for four network calls.
        CompletableFuture.allOf(calls.toArray(CompletableFuture[]::new)).join();

        int total = 0;
        for (int i = 0; i < FILES.size(); i++) {            // list order, NOT completion order
            HttpResponse<String> r = calls.get(i).join();
            int bill = field(r.body(), "mealsPerDay") * field(r.body(), "pricePerMeal") * 30;
            total += bill;
            IO.println("  %-10s -> %d  bill %d".formatted(FILES.get(i), r.statusCode(), bill));
        }
        IO.println("four calls in flight at once, month total: " + total);
    }
}

/// Pull one integer out of JSON with indexOf and substring. The next unit deletes this.
static int field(String json, String key) {
    int at = json.indexOf("\"" + key + "\"");
    int from = json.indexOf(':', at) + 1;
    int to = json.indexOf(',', from);
    return Integer.parseInt(json.substring(from, to).trim());
}
