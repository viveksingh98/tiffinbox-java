# Solution — the preflight that comes back empty

Run from `c6-unit19/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the JVM stops at
once, and `wait "$p"` ends the line with its exit code). The filter is the admin pages' `CorsFilter`, registered as a bean
(`adminCors()`): a `CorsFilter` answers **every** preflight that reaches it — for a path its own rules cover, with their headers; for any
other path, with an empty two hundred, and the request goes no further — so the route's `@CrossOrigin` is never asked. The fix removes the
`@Bean` method and the imports only it used:

```java
    @Bean
    FilterRegistrationBean<CorsFilter> adminCors() {
        …
    }
```

`solution/KitchenCors.java` is the class without them, and nothing else changed (this unit's `exercise` capture prints the diff). The
lines below copy it over your copy, then run the README's last line again, unchanged. Copying the same file twice gives the same file, so
run twice they print the same.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cp exercise/solution/KitchenCors.java .harness/mine/KitchenCors.java
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../KitchenCors.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19488 --spring.main.sources=probe.web.KitchenCors > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19488/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} · Access-Control-Allow-Origin: [%header{access-control-allow-origin}] · Access-Control-Max-Age: [%header{access-control-max-age}]' -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19488/kitchen/menu); ../../../harness/shutdown.sh 19488 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the preflight: $a")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit19/`):

```
the preflight: 200 · Access-Control-Allow-Origin: [http://127.0.0.1:19486] · Access-Control-Max-Age: [1800]
```

The admin pages lose their rule with it. To keep one, give it to Spring MVC's CORS registry (`WebMvcConfigurer.addCorsMappings`)
instead: this unit's `ways` capture measured the registry answering a preflight line for line as `@CrossOrigin` does.
