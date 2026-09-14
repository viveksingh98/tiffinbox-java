# Solution — `-am`

```
mvn -B clean package -pl tiffinbox-kitchen -am -Dmaven.repo.local="$PWD/.m2-demo"
```

`-am` is *also make*: build the modules the selected one depends on. Verified on this Mac, 3 runs,
exit 0 every time; the Reactor Summary (per-module durations removed — they are not facts) reads:

```
[INFO] Reactor Summary for TiffinBox (reactor demo) 1.0.0:
[INFO] 
[INFO] TiffinBox (reactor demo) ........................... SUCCESS 
[INFO] TiffinBox Core ..................................... SUCCESS 
[INFO] TiffinBox Kitchen .................................. SUCCESS 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
```

**Three rows.** The parent came along because `-am` walks *down* the graph — a module's parent POM is
something it depends on. `tiffinbox-web` is absent, because nothing the kitchen needs is in it.
