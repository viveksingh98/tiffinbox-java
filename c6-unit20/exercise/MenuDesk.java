package probe.web;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

/**
 * The exercise's class - the course's, never TiffinBox's: the kitchen's menu desk. POST /kitchen/menu takes one part named "menu"
 * (a multipart request, the way curl -F sends a file) and answers with the file's name and its size. Nothing in it sets a limit:
 * the limits are Boot's, read from Spring's environment when TiffinBox starts. It prints the JVM's locale once, when Spring makes it.
 */
@RestController
public class MenuDesk {

    public MenuDesk() {
        System.out.println("MenuDesk: the JVM's locale: " + Locale.getDefault());
    }

    @PostMapping("/kitchen/menu")
    public Map<String, Object> menu(@RequestPart("menu") MultipartFile menu) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("file", menu.getOriginalFilename());
        m.put("bytes", menu.getSize());
        return m;
    }
}
