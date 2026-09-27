# Unit 32 — What's Next: The Magic, Explained

Course 4 · Section 6 · *Close* — and this unit closes the course. **Verified on JDK 25.0.4.1**, Maven 3.9.16,
Spring Framework 7.0.9. No exercise: the finale's task is the hand-off.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # builds ../c4-tiffinbox, starts it once through harness/Mechanisms, three runs, every row asserted
```

## Every name, printed by the application itself

`java -cp … com.tiffinbox.finale.Mechanisms` · md5 `065beea3ddb242b7d1f49df4e3fa82b8` · 3 of 3

```
the capstone, started once, asked what it is made of:
1. definitions - the recipes the container read
   6 of yours: [tiffinBoxApp, tiffinBoxServer, customerRepository, dashboard, database, orderQueue]
   plus Spring's own infrastructure - the hooks below are among it
2. hooks that run BEFORE any object exists (BeanFactoryPostProcessor): [ConfigurationClassPostProcessor, EventListenerMethodProcessor]
3. hooks that run AROUND every object (BeanPostProcessor): [ApplicationContextAwareProcessor, ImportAwareBeanPostProcessor, BeanPostProcessorChecker, CommonAnnotationBeanPostProcessor, AutowiredAnnotationBeanPostProcessor, ApplicationListenerDetector]
4. a condition: @Profile is itself @Conditional(ProfileCondition)
5. the environment's property sources, in the order they are asked: [systemProperties, systemEnvironment, class path resource [tiffinbox.properties]]
6. proxies among your objects: 0 - every one is the class you wrote
… 4 JUL header line(s), 4 INFO line(s) elided …
```

| row | the mechanism | where this course met it |
|---|---|---|
| 1 | **bean definitions** — the recipes, read before anything is built | the container section's report |
| 2 | **`BeanFactoryPostProcessor`** — edits the recipes before any object exists; `ConfigurationClassPostProcessor` is the one that read `@Configuration`, `@ComponentScan` and `@PropertySource` here | the lifecycle section's early hook |
| 3 | **`BeanPostProcessor`** — handed every object as it is made; `CommonAnnotationBeanPostProcessor` ran `@PostConstruct`, `AutowiredAnnotationBeanPostProcessor` filled `@Value` and the constructors | the lifecycle section; the AOP section's proxy maker is one of these |
| 4 | **`@Conditional`** — a definition registered only if a condition holds; `@Profile` is one | the configuration section's profiles |
| 5 | **the ordered property sources** — first match wins | the configuration section's environment |
| 6 | **proxies** — none in the capstone; every object is the class you wrote | the AOP section, where they were built by hand and by Spring |

## The sentence Core Java II left open

*"Nothing registered anything. The methods declared themselves and reflection went looking. That is also a
fair description of Spring Boot."* The capstone's router still does that for routes. Component scanning did it
for classes — six definitions nobody registered. **Spring Boot's auto-configuration is `@Configuration` classes
guarded by `@Conditional`, found through a list file and read by the same kind of hook as row 2.** That is the
next course's first job; this one gave you the words for it.
