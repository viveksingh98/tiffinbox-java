package probe.web;

import java.lang.reflect.Field;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.Locale;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestClient;

/**
 * The course's harness, never TiffinBox's: a main class run on the anchor's own class path (its extracted lib/), outside
 * com.tiffinbox. Unzip URL asks one URL three times and prints one UNZIP line each - the answer's status, the HTTP version the
 * client used (the JDK's client only: RestClient's answer does not say), its Content-Encoding header ("none" when it has none),
 * the bytes the client handed back, and their md5:
 *   1. the JDK's HttpClient (java.net.http), built with its defaults, no header added;
 *   2. the same client, with Accept-Encoding: gzip set by hand on the request;
 *   3. Spring's RestClient.create() - its request factory read off the client (its field clientRequestFactory, R.135).
 * Nothing is decoded here: what each client hands back is printed as it is. Loopback only: the URL is the argument.
 */
public final class Unzip {

    private Unzip() {
    }

    public static void main(String[] args) throws Exception {
        String url = args[0];
        System.out.println("UNZIP the JVM's locale: " + Locale.getDefault());
        HttpClient jdk = HttpClient.newHttpClient();
        System.out.println("UNZIP the JDK's HttpClient: its default version " + jdk.version());
        for (String asked : new String[] {null, "gzip"}) {
            HttpRequest.Builder b = HttpRequest.newBuilder(URI.create(url));
            if (asked != null) {
                b.header("Accept-Encoding", asked);
            }
            HttpResponse<byte[]> r = jdk.send(b.build(), HttpResponse.BodyHandlers.ofByteArray());
            System.out.println("UNZIP the JDK's HttpClient, " + (asked == null ? "no header added" : "Accept-Encoding: " + asked + " set by hand")
                    + " -> " + r.statusCode() + " " + r.version() + " | Content-Encoding: " + r.headers().firstValue("content-encoding").orElse("none")
                    + " | bytes handed back: " + r.body().length + " | md5 " + md5(r.body()));
        }
        RestClient rest = RestClient.create();
        Field f = rest.getClass().getDeclaredField("clientRequestFactory");
        f.setAccessible(true);
        System.out.println("UNZIP RestClient.create(): its request factory " + f.get(rest).getClass().getName());
        ResponseEntity<byte[]> e = rest.get().uri(url).retrieve().toEntity(byte[].class);
        String ce = e.getHeaders().getFirst("Content-Encoding");
        byte[] body = e.getBody() == null ? new byte[0] : e.getBody();
        System.out.println("UNZIP RestClient.create(), no header added -> " + e.getStatusCode().value() + " | Content-Encoding: " + (ce == null ? "none" : ce)
                + " | bytes handed back: " + body.length + " | md5 " + md5(body));
        System.out.println("UNZIP done");
    }

    private static String md5(byte[] b) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("MD5").digest(b));
    }
}
