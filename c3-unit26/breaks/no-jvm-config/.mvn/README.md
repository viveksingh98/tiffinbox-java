# Why there is an EMPTY jvm.config here

`jvm.config` is **not** a configuration file. It is a raw argument list: every line in it is
handed to the JVM as an argument, with no comment syntax of any kind. A `#` on a line of
its own becomes a main class, and Maven answers

```
Error: Could not find or load main class #
Caused by: java.lang.ClassNotFoundException: #
```

So this file is zero bytes, and the explanation lives here instead.

**It has to exist, and be empty, for this break to be a break.** Maven finds `.mvn` by
walking *up* from the directory you run it in and stops at the first one. This project sits
inside `c3-unit26/`, which has a real `.mvn/jvm.config` — without an empty one here, `mvn`
would quietly inherit the parent's ten flags and the build would succeed, proving nothing.

That is a trap in its own right: a build that works because a directory above it was
configured is a build that stops working the day somebody moves it.
