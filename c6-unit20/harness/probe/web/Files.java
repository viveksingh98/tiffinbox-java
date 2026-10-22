package probe.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import jakarta.servlet.MultipartConfigElement;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

/**
 * The course's harness, never TiffinBox's: a file in, a bill out, and the limits Boot gave Tomcat.
 * <ul>
 * <li>GET /probe/multipart - Boot's MultipartConfigElement bean, read back: the limits Tomcat applies to a multipart request.</li>
 * <li>POST /probe/menu - one part named "menu" ({@code @RequestPart}, a MultipartFile): its file name, its size, the content type the
 * client gave the part, and how many lines it holds.</li>
 * <li>GET /probe/bill/{name} - the customer's month, read from TiffinBox's own CustomerRepository, as CSV: a StreamingResponseBody,
 * written row by row after the handler has returned, with a Content-Disposition that names the file.</li>
 * <li>GET /probe/bill-whole/{name} - the same bytes, whole, as a Resource.</li>
 * </ul>
 * A name nobody has is a 404 with no body, before anything is written. Each step prints a Trace line; a thread is named with its
 * number masked ("task-&lt;n&gt;"). It prints the JVM's locale once, when Spring makes it.
 */
@RestController
public class Files {

    private static final MediaType CSV = new MediaType("text", "csv", StandardCharsets.UTF_8);

    private final MultipartConfigElement multipart;
    private final CustomerRepository customers;

    public Files(MultipartConfigElement multipart, CustomerRepository customers) {
        this.multipart = multipart;
        this.customers = customers;
        Trace.log("Files           the JVM's locale: " + Locale.getDefault());
    }

    static String thread() {
        Thread t = Thread.currentThread();
        return t.getName().replaceAll("[0-9]+$", "<n>") + " (virtual: " + t.isVirtual() + ")";
    }

    @GetMapping("/probe/multipart")
    public Map<String, Object> limits() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("maxFileSize", multipart.getMaxFileSize());
        m.put("maxRequestSize", multipart.getMaxRequestSize());
        m.put("fileSizeThreshold", multipart.getFileSizeThreshold());
        m.put("location", multipart.getLocation());
        return m;
    }

    @PostMapping("/probe/menu")
    public Map<String, Object> menu(@RequestPart("menu") MultipartFile menu) throws IOException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("file", menu.getOriginalFilename());
        m.put("bytes", menu.getSize());
        m.put("type", menu.getContentType());
        m.put("lines", new String(menu.getBytes(), StandardCharsets.UTF_8).lines().count());
        Trace.log("Files           menu: part " + menu.getName() + ", " + menu.getSize() + " bytes");
        return m;
    }

    /** The bill: a header, one row per day of a 30-day month, then the month's total - Customer's own monthlyBill(). */
    static String[] rows(Customer c) {
        String[] r = new String[32];
        r[0] = "day,customer,meals,price per meal,amount";
        for (int d = 1; d <= 30; d++) {
            r[d] = d + "," + c.name() + "," + c.mealsPerDay() + "," + c.pricePerMeal() + "," + c.mealsPerDay() * c.pricePerMeal();
        }
        r[31] = "month," + c.name() + "," + c.mealsPerDay() * 30 + "," + c.pricePerMeal() + "," + c.monthlyBill();
        return r;
    }

    static String disposition(Customer c) {
        return ContentDisposition.attachment().filename("bill " + c.name() + ".csv", StandardCharsets.UTF_8).build().toString();
    }

    @GetMapping("/probe/bill/{name}")
    public ResponseEntity<StreamingResponseBody> streamed(@PathVariable String name) throws SQLException {
        Optional<Customer> found = customers.findByName(name);
        if (found.isEmpty()) {
            Trace.log("Files           bill: no customer " + name + " - 404, nothing written");
            return ResponseEntity.notFound().build();
        }
        Customer c = found.get();
        String[] rows = rows(c);
        String handler = Thread.currentThread().getName();
        StreamingResponseBody body = out -> {
            for (String r : rows) {
                out.write((r + "\n").getBytes(StandardCharsets.UTF_8));
            }
            Trace.log("Files           bill: the body written, " + rows.length + " lines, on " + thread()
                    + ", the handler's thread: " + (Thread.currentThread().getName().equals(handler) ? "yes" : "no"));
        };
        Trace.log("Files           bill: the handler returns, nothing written yet, on " + thread());
        return ResponseEntity.ok().contentType(CSV).header(HttpHeaders.CONTENT_DISPOSITION, disposition(c)).body(body);
    }

    @GetMapping("/probe/bill-whole/{name}")
    public ResponseEntity<Resource> whole(@PathVariable String name) throws SQLException {
        Optional<Customer> found = customers.findByName(name);
        if (found.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        Customer c = found.get();
        byte[] bytes = (String.join("\n", rows(c)) + "\n").getBytes(StandardCharsets.UTF_8);
        Trace.log("Files           bill-whole: the handler returns " + bytes.length + " bytes, whole, on " + thread());
        return ResponseEntity.ok().contentType(CSV).header(HttpHeaders.CONTENT_DISPOSITION, disposition(c)).body(new ByteArrayResource(bytes));
    }
}
