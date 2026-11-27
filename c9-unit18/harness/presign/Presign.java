package probe.u18;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Configuration;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedGetObjectRequest;

import java.net.URI;
import java.time.Duration;
import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * Course 9 unit 18: THE HARNESS'S PRESIGNER (adapted from the S3 probe's Presign.java): the AWS SDK's S3Presigner, run in a container
 * with no network at all. Modes: static (a fake test credential + an explicit region + the endpoint override 127.0.0.1:21079, never
 * bound) · regiononly (an explicit region, the default credentials chain) · default (no region, no credentials). A fake test credential
 * only; no store is called; no request is sent.
 */
public class Presign {
    public static void main(String[] a) {
        String mode = a[0];
        try {
            S3Presigner.Builder b = S3Presigner.builder();
            if (!mode.equals("default")) b.region(Region.of("eu-south-1"));
            if (mode.equals("static")) {
                b.credentialsProvider(StaticCredentialsProvider.create(AwsBasicCredentials.create("FAKETESTONLYU18", "a-fake-test-credential-u18")))
                 .endpointOverride(URI.create("http://127.0.0.1:21079"))
                 .serviceConfiguration(S3Configuration.builder().pathStyleAccessEnabled(true).build());
            }
            try (S3Presigner p = b.build()) {
                PresignedGetObjectRequest r = p.presignGetObject(GetObjectPresignRequest.builder().signatureDuration(Duration.ofMinutes(5))
                        .getObjectRequest(g -> g.bucket("tiffinbox-bills").key("bill-Ravi.csv")).build());
                URI u = r.url().toURI();
                String keys = Arrays.stream(u.getRawQuery().split("&")).map(kv -> kv.split("=")[0]).collect(Collectors.joining(","));
                System.out.println("PRESIGN " + mode + " · OK · " + u.getScheme() + "://" + u.getHost() + ":" + u.getPort() + u.getRawPath()
                        + " · query keys [" + keys + "] · X-Amz-Expires=" + param(u, "X-Amz-Expires") + " · X-Amz-Algorithm=" + param(u, "X-Amz-Algorithm")
                        + " · isBrowserExecutable " + r.isBrowserExecutable() + " · signed headers " + r.signedHeaders().keySet()
                        + " · expiration <masked> · signature <masked, " + param(u, "X-Amz-Signature").length() + " hex chars>");
            }
        } catch (Throwable t) {
            System.out.println("PRESIGN " + mode + " · FAILED · " + t.getClass().getName() + ": " + t.getMessage());
        }
    }

    static String param(URI u, String k) {
        for (String kv : u.getRawQuery().split("&")) if (kv.startsWith(k + "=")) return kv.substring(k.length() + 1);
        return "";
    }
}
