# Solution

Measured 2026-09-29 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1), by running `../README.md`'s block **exactly as
written**, from `exercise/`, in a clean shell (`env -i`, so nothing but the block's own two `export` lines chose the JDK).
Its whole output — two lines, and no `WARN` or `ERROR` line from either run:

```
  definitions in all: 55 · yours 6 · listed auto-configuration classes registered 9 · everything else 40
  definitions in all: 49 · yours 6 · listed auto-configuration classes registered 8 · everything else 35
```

**The short name did nothing, and said nothing.** `TaskSchedulingAutoConfiguration` is not a name any class has; the file
lists `org.springframework.boot.autoconfigure.task.TaskSchedulingAutoConfiguration`. The first run is the plain count
(55, registered 9), exit 0, 0 `WARN` lines, 0 `ERROR` lines. Why silent: Boot complains about an exclude only when it
can **load** that class and finds it is not an auto-configuration. Measured with a class it can load:
`-Dspring.autoconfigure.exclude=com.tiffinbox.Database` → exit 1, `java.lang.IllegalStateException: The following
classes could not be excluded because they are not auto-configuration classes:` `- com.tiffinbox.Database`. A name it
cannot load is skipped without a word.

**The full name removed six definitions** (55 → 49), and the list now says `not used    not evaluated
TaskSchedulingAutoConfiguration` (Boot's report covers 11 of the 12: an excluded class is never evaluated). The six,
read off `AutoConfig defs` with the exclude against the plain run:

```
org.springframework.boot.autoconfigure.task.TaskSchedulingAutoConfiguration                                       configuration class
org.springframework.boot.autoconfigure.task.TaskSchedulingConfigurations$SimpleAsyncTaskSchedulerBuilderConfiguration   configuration class
org.springframework.boot.autoconfigure.task.TaskSchedulingConfigurations$ThreadPoolTaskSchedulerBuilderConfiguration    configuration class
simpleAsyncTaskSchedulerBuilder                                                                                    @Bean method
threadPoolTaskSchedulerBuilder                                                                                     @Bean method
spring.task.scheduling-org.springframework.boot.autoconfigure.task.TaskSchedulingProperties                         registered by code
```

An auto-configuration class is a configuration class like yours: it imports more configuration classes, those carry
`@Bean` methods, and its `@EnableConfigurationProperties` registers a properties holder. Excluding it removes everything
it would have described — one entry in the file, six definitions in the container.
