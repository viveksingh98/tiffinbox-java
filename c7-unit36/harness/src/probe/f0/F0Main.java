package probe.f0;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;

/** Unit 36's labelled run: TiffinBox's entities, Flyway's own jars on the class path, Boot's Flyway module not - nothing here names Flyway. */
@SpringBootApplication
@EntityScan("com.tiffinbox")
public class F0Main {
    public static void main(String[] args) throws Exception {
        probe.f.Run.run(F0Main.class, args);
    }
}
