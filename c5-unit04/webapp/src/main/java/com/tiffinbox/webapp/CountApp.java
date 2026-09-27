package com.tiffinbox.webapp;

import java.io.InputStream;
import java.net.URL;
import java.util.Enumeration;
import java.util.Map;
import java.util.TreeMap;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Starts, counts, stops. Port 18551 on loopback; the banner and INFO logging are switched off so the counts stand alone. */
@SpringBootApplication
public class CountApp {
    public static void main(String[] args) throws Exception {
        var ctx = SpringApplication.run(CountApp.class, "--server.port=18551", "--server.address=127.0.0.1",
                "--spring.main.banner-mode=off", "--logging.level.root=warn");
        Map<String, Integer> perJar = new TreeMap<>();
        Enumeration<URL> urls = CountApp.class.getClassLoader()
                .getResources("META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports");
        while (urls.hasMoreElements()) {
            URL u = urls.nextElement();
            String jar = u.getPath().replaceAll("!.*$", "").replaceAll("^.*/", "");
            int n = 0;
            try (InputStream in = u.openStream()) {
                for (String l : new String(in.readAllBytes()).split("\n")) if (!l.isBlank() && !l.strip().startsWith("#")) n++;
            }
            perJar.put(jar, n);
        }
        System.out.println("a Boot web application with one starter:");
        perJar.forEach((jar, n) -> System.out.printf("  %-44s %3d classes listed%n", jar, n));
        System.out.println("  imports files " + perJar.size() + " · classes listed "
                + perJar.values().stream().mapToInt(Integer::intValue).sum() + " · bean definitions " + ctx.getBeanDefinitionCount());
        ctx.close();
    }
}
