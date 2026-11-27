package probe.u18;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

/**
 * THE HARNESS'S BLOB ROUTE (Course 9 unit 18; adapted from the S3 probe's blob handler, its path moved under /probe/u18/): a large
 * proxied payload - n MiB of zero bytes, streamed in 64 KiB writes through TiffinBox's JVM, with no store behind it. Never shipped.
 */
@RestController
public class U18Blob {

    @GetMapping("/probe/u18/blob")
    ResponseEntity<StreamingResponseBody> blob(@RequestParam(defaultValue = "8") int mib) {
        StreamingResponseBody body = out -> {
            byte[] chunk = new byte[64 * 1024];
            for (int i = 0; i < mib * 16; i++) out.write(chunk);
        };
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_OCTET_STREAM).body(body);
    }
}
