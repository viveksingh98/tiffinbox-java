# Exercise — the line that registers a route

**Your turn:** switch on TRACE for the request mapping class, restart, and find the line that registered the harness route. What
does it print?

In the video, Spring MVC registered the harness's `@GetMapping` method while TiffinBox started, before Tomcat started — one TRACE
line per method. The command below is meant to show that line, and shows none: its logging option names the wrong class.

Run everything from `c6-unit03/`. The command starts the copy this unit's `receipts.sh` builds in `.harness/serve` — the anchor
with Spring MVC's starter added — from that folder, which holds a config tree with the demo token; the harness's classes are in
`.harness/classes`. Both are git-ignored, and `receipts.sh` makes them: on a fresh clone, run `./receipts.sh` once first. The run
uses `-Dspring.context.exit=onRefresh`, the property the last course's AOT-cache line uses: the JVM starts, refreshes the context
— that is when a route is registered — and exits by itself, before Tomcat listens. TiffinBox's own server listens on
`127.0.0.1:19320` for that moment; nothing is left running.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd .harness/serve && java -Dspring.context.exit=onRefresh -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19320 --server.address=127.0.0.1 --server.port=19321 --spring.main.sources=probe.Hello --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter=trace > ../mine.log && echo "lines that register a route: $(grep -c '{GET' ../mine.log)"
```

It prints `lines that register a route: 0`. Change the logging option so that it names the class that finds handlers and
registers routes, run it again, and print the line for `/probe/hello` from `.harness/mine.log`.

**Done** when you can print

```
{GET [/probe/hello]}: hello()
```

— the verb, the path pattern, and the method Spring MVC will call. The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
