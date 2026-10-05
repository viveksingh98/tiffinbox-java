# Exercise — two main classes, and the build that has to choose

**Your turn:** add a second class with a main method, package, then make the build choose TiffinBox again without
deleting it.

Boot's `repackage` writes the jar's `Start-Class` — the class its launcher hands control to. Nobody told it which one: it
found the one class in `tiffinbox-web` with a `main` method. This exercise gives it two.

Run everything from `c5-unit13/`, in a copy of `after/` under `.harness/mine` (git-ignored; `receipts.sh` wipes
`.harness/` when it runs). Builds use this unit's own repository, `.m2-demo`, offline.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness && rsync -a --exclude target after/ .harness/mine/
mkdir -p .harness/mine/tiffinbox-web/src/main/java/com/tiffinbox/web/tools
cp exercise/PrintRoutes.java .harness/mine/tiffinbox-web/src/main/java/com/tiffinbox/web/tools/
mvn -o -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package | grep -m1 -oE 'Unable to find a single main class from the following candidates \[[^]]*\]'
```

`PrintRoutes` (this folder) is a small tool with its own `main`: it prints TiffinBox's routes, read off the `@Route`
annotations, and starts nothing. With it in place, the build stops — the last command prints the reason:

```
Unable to find a single main class from the following candidates [com.tiffinbox.web.TiffinBoxServer, com.tiffinbox.web.tools.PrintRoutes]
```

Now make the build choose `com.tiffinbox.web.TiffinBoxServer` — **keep `PrintRoutes.java` where it is**, and change only
`.harness/mine/tiffinbox-web/pom.xml`. Hint: Boot's parent configures the plugin's main class from a property. Find it:

```bash
grep -n 'start-class\|main-class' .m2-demo/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom
```

Then package again and read the manifest:

```bash
mvn -o -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package | grep -E '^\[INFO\] BUILD'
unzip -p .harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF | grep -E '^(Main|Start)-Class'
unzip -l .harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -c 'tools/PrintRoutes.class'
```

**Done** when the build says `BUILD SUCCESS`, the manifest says

```
Main-Class: org.springframework.boot.loader.launch.JarLauncher
Start-Class: com.tiffinbox.web.TiffinBoxServer
```

and `PrintRoutes.class` is still in the jar (`1`). The same two end states are lines of this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
