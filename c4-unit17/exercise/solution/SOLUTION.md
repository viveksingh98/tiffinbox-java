# Solution

## 1 — Find it

```
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" package -DskipTests
jar tf target/c4-unit17-exercise-1.0.0.jar | grep csv
```

Nothing. The file is in the repository and not in the artefact.

## 2 — Fix it

```
mkdir -p src/main/resources/com/tiffinbox
git mv src/main/java/com/tiffinbox/menu.csv src/main/resources/com/tiffinbox/menu.csv
```

No code change. `classpath:com/tiffinbox/menu.csv` still names it, because the resource root and the
source root produce the same class-path layout — which is exactly why the mistake is invisible.

## 3 — Why Maven treats them differently

`src/main/java` is compiled: the `maven-compiler-plugin` reads `.java` files from it and writes
`.class` files to `target/classes`. **Nothing else in that directory is its business.**
`src/main/resources` is copied: the `maven-resources-plugin` copies it wholesale into
`target/classes`. Two plugins, two jobs, one output directory — and only one of them has ever heard
of your CSV.

Your IDE muddies this because it usually copies non-Java files out of a source root as a
convenience, so the file appears in the output while you develop. That convenience is the bug: the
build you ship does not have it, and nothing tells you until something opens the file.

**The general rule this unit is really teaching:** a `classpath:` location is a statement about the
artefact, and the only honest way to check it is to look in the artefact.
