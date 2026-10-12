# Solution — the line that registers a route

Run from `c6-unit03/`, after `exercise/README.md`'s commands. One line: the same start, the logging option naming
`RequestMappingHandlerMapping` — the handler mapping, which finds annotated methods and registers them — instead of
`RequestMappingHandlerAdapter`, which calls them once found and registers nothing; then the line for `/probe/hello`, its tab cut.

```bash
cd .harness/serve && java -Dspring.context.exit=onRefresh -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19320 --server.address=127.0.0.1 --server.port=19321 --spring.main.sources=probe.Hello --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace > ../mine.log && grep -F '[/probe/hello]' ../mine.log | tr -d '\t'
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-12):

```
{GET [/probe/hello]}: hello()
```

At TRACE the adapter prints two lines of its own while TiffinBox starts — the advice beans it found, and its cache setting — and no
route: registering is the mapping's job.
