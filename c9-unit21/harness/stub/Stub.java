/// Stub.java - a stub: a small stand-in server that answers like the real one would, on this computer only. The JDK's own
/// HTTP server (com.sun.net.httpserver, module jdk.httpserver), one source file, no dependency, no build - the JDK's source
/// launcher compiles it in memory and runs it:
///     java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19546 --www=harness/stub/www
/// It binds InetAddress.getLoopbackAddress() (127.0.0.1) and serves each request on a virtual thread. It prints every request
/// whole - "STUB <method> <uri> headers=[names]", one "STUB-H name: value" per value of each header (the name lower-cased), "STUB-BODY <body>"
/// when a body came - and then its own answer, "STUB-ANSWER <status> <content type> <bytes> bytes". That dump is the witness of
/// what a client sent. The course's harness, never TiffinBox's: the client lessons copy this file byte for byte.
///   GET /<file>             a file of --www (Core Java II's five), 200 application/json; anything else 404 text/plain "not found"
///   GET /status/<code>      that status, application/json {"status":<code>,"from":"stub"}
///   GET .../slow[?ms=N]     waits N milliseconds (3000 unless named), then 200 {"slow":true}
///   GET /redirect           302, Location: /ravi.json
///   GET /events             text/event-stream: three events, 400 ms apart
///   POST /payments          201 + Location /payments/pay-<n> and the payment; 422 problem+json when "amount":0
///   GET /payments/<id>      200 the payment; 404 problem+json when there is none
import module jdk.httpserver;

final java.util.concurrent.atomic.AtomicInteger next = new java.util.concurrent.atomic.AtomicInteger();
final Map<String, String> payments = new java.util.concurrent.ConcurrentHashMap<>();

void main(String[] args) throws Exception {
    int port = -1;
    Path www = null;
    for (String a : args) {
        if (a.startsWith("--port=")) port = Integer.parseInt(a.substring(7));
        else if (a.startsWith("--www=")) www = Path.of(a.substring(6));
        else throw new IllegalArgumentException("unknown argument: " + a);
    }
    if (port < 0 || www == null) throw new IllegalArgumentException("usage: java Stub.java --port=<port> --www=<folder>");
    Path root = www.toAbsolutePath().normalize();
    HttpServer server = HttpServer.create(new InetSocketAddress(InetAddress.getLoopbackAddress(), port), 0);
    server.setExecutor(java.util.concurrent.Executors.newVirtualThreadPerTaskExecutor());
    server.createContext("/", ex -> {
        try (ex) {
            String m = ex.getRequestMethod(), p = ex.getRequestURI().getPath(), q = ex.getRequestURI().getQuery();
            var names = new TreeSet<String>(String.CASE_INSENSITIVE_ORDER);
            names.addAll(ex.getRequestHeaders().keySet());
            IO.println("STUB " + m + " " + ex.getRequestURI() + " headers=" + names);
            for (String n : names) for (String v : ex.getRequestHeaders().get(n)) IO.println("STUB-H " + n.toLowerCase(Locale.ROOT) + ": " + v);
            byte[] in = ex.getRequestBody().readAllBytes();
            if (in.length > 0) IO.println("STUB-BODY " + new String(in, StandardCharsets.UTF_8));
            if (p.endsWith("/slow")) {
                Thread.sleep(q != null && q.startsWith("ms=") ? Long.parseLong(q.substring(3)) : 3000);
                send(ex, 200, "application/json", "{\"slow\":true}");
            } else if (p.equals("/events")) {
                ex.getResponseHeaders().add("Content-Type", "text/event-stream");
                ex.sendResponseHeaders(200, 0);
                IO.println("STUB-ANSWER 200 text/event-stream (a stream)");
                for (int i = 1; i <= 3; i++) {
                    ex.getResponseBody().write(("data: order " + i + "\n\n").getBytes(StandardCharsets.UTF_8));
                    ex.getResponseBody().flush();
                    Thread.sleep(400);
                }
            } else if (p.equals("/redirect")) {
                ex.getResponseHeaders().add("Location", "/ravi.json");
                send(ex, 302, "text/plain", "moved");
            } else if (p.startsWith("/status/")) {
                int code = Integer.parseInt(p.substring(8));
                send(ex, code, "application/json", "{\"status\":" + code + ",\"from\":\"stub\"}");
            } else if (p.equals("/payments") && m.equals("POST")) {
                String body = new String(in, StandardCharsets.UTF_8);
                if (body.contains("\"amount\":0")) {
                    send(ex, 422, "application/problem+json", "{\"title\":\"Unprocessable\",\"status\":422,\"detail\":\"amount must be positive\"}");
                    return;
                }
                String id = "pay-" + next.incrementAndGet();
                String rec = "{\"id\":\"" + id + "\",\"status\":\"PAID\"," + body.substring(body.indexOf('{') + 1);
                payments.put(id, rec);
                ex.getResponseHeaders().add("Location", "/payments/" + id);
                send(ex, 201, "application/json", rec);
            } else if (p.startsWith("/payments/") && m.equals("GET")) {
                String id = p.substring(10), rec = payments.get(id);
                if (rec == null) send(ex, 404, "application/problem+json", "{\"title\":\"Not Found\",\"status\":404,\"detail\":\"no payment " + id + "\"}");
                else send(ex, 200, "application/json", rec);
            } else {
                Path f = root.resolve(p.substring(1)).normalize();
                if (m.equals("GET") && f.startsWith(root) && Files.isRegularFile(f)) send(ex, 200, "application/json", Files.readString(f));
                else send(ex, 404, "text/plain", "not found");
            }
        } catch (Exception e) {
            IO.println("STUB-FAIL " + e);
        }
    });
    server.start();
    IO.println("STUB the JVM's locale: " + Locale.getDefault());
    IO.println("STUB listening on " + server.getAddress());
}

void send(HttpExchange ex, int code, String type, String body) throws java.io.IOException {
    byte[] b = body.getBytes(StandardCharsets.UTF_8);
    ex.getResponseHeaders().add("Content-Type", type);
    IO.println("STUB-ANSWER " + code + " " + type + " " + b.length + " bytes");
    ex.sendResponseHeaders(code, b.length);
    ex.getResponseBody().write(b);
}
