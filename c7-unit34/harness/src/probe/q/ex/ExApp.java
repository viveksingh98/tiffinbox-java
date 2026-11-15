package probe.q.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.HexFormat;

/**
 * The exercise's application: a Spring Boot application with no web server, in its own package, probe.q.ex, with two entities of its
 * own - Diner (a name; this exercise's customer) and Break (a diner's days off, its own table break_day; this exercise's pause), the
 * break owning the foreign key, @ManyToOne + @JoinColumn(name = "diner_id"), as TiffinBox's pause does. Hibernate writes its schema
 * script for them to a file (jakarta.persistence.schema-generation.scripts.action=create, the target given by the arguments; nothing
 * runs it, ddl-auto=none) in this JVM's own H2 database in memory - no port, no container, never TiffinBox's tables. The runner reads
 * the file back and prints its line count, the lines that hold "index" and the file's md5.
 */
@SpringBootApplication
public class ExApp {
    @Entity
    @Table(name = "diner")
    public static class Diner {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        String name;
    }

    @Entity
    @Table(name = "break_day")
    public static class Break {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "diner_id") Diner diner;
        int days;
    }

    @Bean
    CommandLineRunner show(org.springframework.core.env.Environment env) {
        return a -> {
            Path f = Path.of(env.getProperty("spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target"));
            var lines = Files.readAllLines(f);
            System.out.println("PROBE Hibernate's schema script: " + lines.size() + " lines · lines with \"index\": "
                + lines.stream().filter(l -> l.contains("index")).count() + " · md5 " + HexFormat.of().formatHex(MessageDigest.getInstance("MD5").digest(Files.readAllBytes(f))));
            lines.stream().filter(l -> l.contains("index")).forEach(l -> System.out.println("PROBE " + l));
        };
    }

    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }
}
