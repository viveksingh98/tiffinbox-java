package probe.u14;

import org.springframework.http.ResponseEntity;
import org.springframework.http.client.ClientHttpRequestFactory;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

import java.lang.reflect.Field;
import java.security.MessageDigest;
import java.util.HexFormat;

/** THE HARNESS'S CLIENT (Course 9 unit 14's receipts; the S3 probe's Gzip.java, a named diff: the package, this line, and its User-Agent override removed - each client sends its own): what three clients ask for and what each hands back. Usage: Gzip14 URL. */
public class Gzip14 {
    public static void main(String[] a) throws Exception {
        String url = a[0];
        one("HttpComponentsClientHttpRequestFactory (new, default HttpClient)", RestClient.builder().requestFactory(new HttpComponentsClientHttpRequestFactory()).build(), url);
        RestClient created = RestClient.create();
        one("RestClient.create()", created, url);
        one("JdkClientHttpRequestFactory (new)", RestClient.builder().requestFactory(new JdkClientHttpRequestFactory()).build(), url);
    }

    static void one(String label, RestClient c, String url) throws Exception {
        ResponseEntity<byte[]> r = c.get().uri(url).retrieve().toEntity(byte[].class);
        byte[] b = r.getBody() == null ? new byte[0] : r.getBody();
        String md5 = HexFormat.of().formatHex(MessageDigest.getInstance("MD5").digest(b));
        System.out.println("CLIENT " + label + " · factory " + factory(c) + " · status " + r.getStatusCode().value()
                + " · Content-Encoding " + r.getHeaders().getFirst("Content-Encoding") + " · Content-Length " + r.getHeaders().getFirst("Content-Length")
                + " · Vary " + r.getHeaders().getFirst("Vary") + " · bytes handed back " + b.length + " · md5 " + md5);
    }

    static String factory(RestClient c) throws Exception {
        Field f = c.getClass().getDeclaredField("clientRequestFactory");
        f.setAccessible(true);
        ClientHttpRequestFactory rf = (ClientHttpRequestFactory) f.get(c);
        return rf.getClass().getName();
    }
}
