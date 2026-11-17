package probe.l;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;

/** The anchor's two entities alone (com.tiffinbox's CustomerEntity and PauseEntity) and Boot's auto-configuration: Liquibase, Flyway, both or neither, as the class path and the arguments say. */
@SpringBootApplication
@EntityScan("com.tiffinbox")
public class LMain {
    public static void main(String[] args) throws Exception {
        Run.run(LMain.class, args);
    }
}
