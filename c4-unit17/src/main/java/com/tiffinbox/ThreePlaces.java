package com.tiffinbox;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.HexFormat;
import com.sun.net.httpserver.HttpServer;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

/**
 * The same menu, in three different places, read through ONE api.
 *
 * <p>classpath:, file: and http: are three prefixes on one ResourceLoader — not three libraries and
 * not three code paths in your program. getDescription() is printed so you can see WHICH one
 * answered, and the bytes are HASHED rather than eyeballed, because three panels that look alike
 * are not evidence that they are alike.
 *
 * <p>THE HTTP CASE IS A LOOPBACK SERVER, DELIBERATELY. It binds
 * InetAddress.getLoopbackAddress(), it is the jdk.httpserver the viewer built in Course 2, and
 * nothing in this course reaches the network. Started by this main rather than by a @Bean: a
 * server bean that fails to bind turns a resources lesson into a lifecycle debugging session, and
 * unit 08 is where lifecycle lives. A real application would make it a bean, and unit 08 says what
 * that costs.
 *
 * <p>The server is stopped in a finally, so a second run does not meet a port the first one kept.
 */
public final class ThreePlaces {

    private ThreePlaces() { }

    public static void main(String[] args) throws Exception {
        byte[] menu = ThreePlaces.class.getResourceAsStream("/menu.csv").readAllBytes();

        // file: — the same bytes written to a temp file, so the three really are the same menu.
        Path onDisk = Files.createTempFile("tiffinbox-menu", ".csv");
        Files.write(onDisk, menu);

        // http: — loopback only.
        HttpServer server = HttpServer.create(
                new InetSocketAddress(InetAddress.getLoopbackAddress(), 0), 0);
        server.createContext("/menu.csv", exchange -> {
            exchange.sendResponseHeaders(200, menu.length);
            try (var out = exchange.getResponseBody()) { out.write(menu); }
        });
        server.start();
        int port = server.getAddress().getPort();
        System.out.println("loopback server on " + InetAddress.getLoopbackAddress().getHostAddress()
                + ":<port>   (a port the OS chose; nothing leaves this machine)");

        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext()) {
            ctx.refresh();
            ResourceLoader loader = ctx;               // the context IS a ResourceLoader

            String[] locations = {
                "classpath:menu.csv",
                "file:" + onDisk,
                "http://" + InetAddress.getLoopbackAddress().getHostAddress() + ":" + port + "/menu.csv",
            };

            String first = null;
            int same = 0;
            for (String location : locations) {
                Resource r = loader.getResource(location);
                String digest = md5(r);
                if (first == null) { first = digest; }
                if (digest.equals(first)) { same++; }
                System.out.printf("  %-11s %-58s md5 %s%n",
                        location.split(":")[0] + ":", describe(r), digest);
            }
            System.out.println("locations=" + locations.length + "  identical bytes=" + same);
            if (same != locations.length) {
                die("the three locations did not return the same bytes. The point of this capture "
                        + "is that they do; with different bytes it shows nothing about one API.");
            }
            System.out.println("one ResourceLoader answered all " + locations.length
                    + ", and getResource returned a " + loader.getResource(locations[0])
                        .getClass().getSimpleName() + " for the first one.");
        } finally {
            server.stop(0);
            Files.deleteIfExists(onDisk);
        }
    }

    /** Descriptions carry absolute paths and the OS temp directory; both are masked. */
    static String describe(Resource r) {
        String tmp = System.getProperty("java.io.tmpdir").replaceAll("/+$", "");   // Linux /tmp too (RED 2026-09-26)
        return r.getDescription()
                .replaceAll("/var/folders/[^\\]\\s]*", "<tmp>/tiffinbox-menu.csv")
                .replaceAll(java.util.regex.Pattern.quote(tmp) + "/[^\\]\\s]*", "<tmp>/tiffinbox-menu.csv")
                .replaceAll(":\\d{4,5}/", ":<port>/");
    }

    static String md5(Resource r) throws IOException {
        try (InputStream in = r.getInputStream()) {
            MessageDigest d = MessageDigest.getInstance("MD5");
            return HexFormat.of().formatHex(d.digest(in.readAllBytes()));
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    static void die(String why) {
        System.out.flush();
        System.err.println("ThreePlaces: " + why);
        System.exit(2);
    }
}
