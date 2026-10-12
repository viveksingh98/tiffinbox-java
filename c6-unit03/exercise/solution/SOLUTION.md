# Solution — the line that registers a route

Run from `c6-unit03/`, after `exercise/README.md`'s commands, in the same shell. One line: the same start, in a subshell, the
logging option naming `RequestMappingHandlerMapping` — the handler mapping, which finds annotated methods and registers them —
instead of `RequestMappingHandlerAdapter`, which calls them once found and registers nothing; then the line for `/probe/hello`, its
tab cut.

```bash
(cd .harness/serve && exec java -Dspring.context.exit=onRefresh -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19320 --server.address=127.0.0.1 --server.port=19321 --spring.main.sources=probe.Hello --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace) > .harness/mine.log && grep -F '[/probe/hello]' .harness/mine.log | tr -d '\t'
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-13 — run in the same shell as the README's commands, which left
it in `c6-unit03/`):

```
{GET [/probe/hello]}: hello()
```

At TRACE the adapter prints two lines of its own while TiffinBox starts — the advice beans it found, and its cache setting — and no
route: registering is the mapping's job.
