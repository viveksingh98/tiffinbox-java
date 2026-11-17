package probe.d;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;

/** The anchor's two entities alone (com.tiffinbox's CustomerEntity and PauseEntity): no Database bean, no repository, no seed. */
@SpringBootApplication
@EntityScan("com.tiffinbox")
public class Main {
    public static void main(String[] args) {
        Run.run(Main.class, args);
    }
}
