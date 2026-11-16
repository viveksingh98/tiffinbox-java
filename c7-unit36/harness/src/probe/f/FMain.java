package probe.f;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.flyway.autoconfigure.FlywayMigrationStrategy;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;

/**
 * Unit 36: TiffinBox's two entities and whatever migration tool the class path holds - Boot's auto-configuration decides. With
 * --probe.repair=true a FlywayMigrationStrategy bean calls repair() and then migrate(): the one hook Boot gives instead of a command.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
public class FMain {
    public static void main(String[] args) throws Exception {
        Run.run(FMain.class, args);
    }

    @Bean
    @ConditionalOnProperty(name = "probe.repair", havingValue = "true")
    FlywayMigrationStrategy repairThenMigrate() {
        return flyway -> {
            flyway.repair();
            flyway.migrate();
        };
    }
}
