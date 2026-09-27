# Unit 32 — What's Next: The Magic, Explained

Course 4 · Section 6 · *Close* — and this unit closes the course. **Verified on JDK 25.0.4.1**, Maven 3.9.16,
Spring Framework 7.0.9. No exercise: the finale's task is the hand-off.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # builds ../c4-tiffinbox, asks it what it is made of - whole, then one hook out at a time; 3 runs each
```

The `.r-*.out` captures are not committed: `receipts.sh` regenerates them, requires three identical runs, and
compares each hash with `receipts.md5`. Every JVM is pinned to en-US (Java's log header is locale-dependent).
`Mechanisms` runs with `--add-opens java.base/java.lang=ALL-UNNAMED` for one reason: row 0 asks the class loader
whether a class has been loaded yet, and `findLoadedClass` is not public.

## Every name, printed by the application itself

`harness/com/tiffinbox/finale/Mechanisms` · `.r-mechanisms.out` `db4d2901d7793db30ce5d6cdbd2cb3d1` · 3 of 3

```
the capstone, asked what it is made of:
0. the scan, on its own, before anything is built: 6 classes found in com.tiffinbox - loaded by the JVM: 0 of 6
INFO: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
   the same classes, after the container built them - loaded by the JVM: 6 of 6
1. definitions - the recipes the container read, before any of your objects existed
   6 of yours: [customerRepository, dashboard, database, orderQueue, tiffinBoxApp, tiffinBoxServer]
   handed in: [tiffinBoxApp] - found by the scan: 5
   plus Spring's own infrastructure - the hooks below are among it
2. hooks that run BEFORE any of your objects exist (BeanFactoryPostProcessor): [ConfigurationClassPostProcessor, EventListenerMethodProcessor]
3. hooks handed each of your objects as the container makes it (BeanPostProcessor): [ApplicationContextAwareProcessor, ImportAwareBeanPostProcessor, BeanPostProcessorChecker, CommonAnnotationBeanPostProcessor, AutowiredAnnotationBeanPostProcessor, ApplicationListenerDetector]
4. a condition: @Profile is itself @Conditional(ProfileCondition)
5. the environment's property sources, in the order they are asked: [systemProperties, systemEnvironment, class path resource [tiffinbox.properties]]
6. proxies among your objects: 0 - every one is the class you wrote
   your configuration class: @Bean methods 0 - the object's class: com.tiffinbox.web.TiffinBoxApp
   for contrast, contrast.OneBeanMethod, one @Bean method - its recipe's class after the row-2 hook: contrast.OneBeanMethod$$SpringCGLIB$$0
   the aspect section's proxy maker, AbstractAutoProxyCreator - a BeanPostProcessor? true
… 4 JUL header line(s), 3 other INFO line(s), 0 WARNING line(s) elided …
```

## Each hook, taken out

Rows 2 and 3 are names. `harness/…/TakeOneOut` starts the capstone three more times, each time without ONE of them,
so what each one does is measured (`.r-takeout.out` `4a1bbe00d681d94ce1d96aa52f5c074c`):

```
without ConfigurationClassPostProcessor: the context started - yours [tiffinBoxApp] - sources [systemProperties, systemEnvironment]
… 0 JUL header line(s), 0 other INFO line(s), 0 WARNING line(s) elided …
without CommonAnnotationBeanPostProcessor: the context started - yours [tiffinBoxApp, tiffinBoxServer, customerRepository, dashboard, database, orderQueue] - sources [systemProperties, systemEnvironment, class path resource [tiffinbox.properties]] - start() ran? false - orders cooked 0
… 0 JUL header line(s), 0 other INFO line(s), 0 WARNING line(s) elided …
without AutowiredAnnotationBeanPostProcessor: the context refused to start - BeanCreationException, root cause java.lang.NoSuchMethodException: com.tiffinbox.web.TiffinBoxServer.<init>()
… 1 JUL header line(s), 0 other INFO line(s), 1 WARNING line(s) elided …
```

| row | the mechanism | measured here | where this course met it |
|---|---|---|---|
| 0 | **the scan reads bytes** — six classes found, none loaded | 0 of 6 loaded after the scan; 6 of 6 once built | the container section's scanning |
| 1 | **bean definitions** — the recipes, read before any of your objects exist | 6 of yours: 1 handed in, 5 found by the scan | the container section's report |
| 2 | **`BeanFactoryPostProcessor`** — edits the recipes before any of your objects exist | without `ConfigurationClassPostProcessor`: no scan, no file — yours `[tiffinBoxApp]` | the lifecycle section's early hook |
| 3 | **`BeanPostProcessor`** — handed each object as the container makes it | without `CommonAnnotationBeanPostProcessor`, `start()` never ran; without `AutowiredAnnotationBeanPostProcessor`, no constructor could be chosen (`NoSuchMethodException … <init>()`). It **chose** the constructors; the `@Value` parameters were resolved by the bean factory | the lifecycle section |
| 4 | **`@Conditional`** — a definition registered only if a condition holds; `@Profile` is one | `@Profile` is itself `@Conditional(ProfileCondition)` | the configuration section's profiles |
| 5 | **the ordered property sources** — the first one that has the key answers | system properties, then the operating system's environment variables, then the file | the configuration section's environment |
| 6 | **proxies and subclasses** — none in the capstone | its configuration class has no `@Bean` method and stays plain; one `@Bean` method and the row-2 hook rewrites the recipe to a CGLIB subclass; the AOP proxy maker is a row-3 kind of hook | the configuration-class unit; the AOP section (`c4-unit20`: `@EnableAspectJAutoProxy` adds `internalAutoProxyCreator`) |

**A correction this unit makes.** The configuration-class unit said *"your configuration class gets subclassed"*. On
Spring Framework 7.0.9 that holds for a configuration class **with `@Bean` methods** — the case that unit measured. A
configuration class without any, like the capstone's, is left plain (row 6).

## The sentence Core Java II left open

*"Nothing registered anything. The methods declared themselves and reflection went looking. That is also a fair
description of Spring Boot."* The capstone's router still does exactly that for routes (the `routes mapped:` line
above, kept from the server's own log). The scan did it for classes — **five of the six** definitions were found, the
sixth is the class handed to the context — and it did it **without reflection**: it read the class files as bytes, and
not one of the six classes had been loaded when it finished (row 0).

**Spring Boot's auto-configuration** is configuration classes — most of them guarded by conditions — listed in a file
and read by the very hook in row 2. Three of those four parts were measured in this course; the file is the next
course's to open.
