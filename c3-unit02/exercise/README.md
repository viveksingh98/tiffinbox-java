# Exercise — one flag

**Warm the repository once** (this also proves the four-module reactor works):

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25 && export PATH="$JAVA_HOME/bin:$PATH"
cd ..                       # c3-unit02/
mvn -B clean package -Dmaven.repo.local="$PWD/.m2-demo"
```

**Start state** — this command fails, exit 1:

```
mvn -B clean package -pl tiffinbox-kitchen -Dmaven.repo.local="$PWD/.m2-demo"
```
```
[ERROR] Failed to execute goal on project tiffinbox-kitchen: Could not resolve dependencies for project com.tiffinbox:tiffinbox-kitchen:jar:1.0.0
[ERROR] dependency: com.tiffinbox:tiffinbox-core:jar:1.0.0 (compile)
[ERROR] 	Could not find artifact com.tiffinbox:tiffinbox-core:jar:1.0.0 in central (https://repo.maven.apache.org/maven2)
```

**Task:** add **one flag** so it passes.

**End state:** the **Reactor Summary lists three modules** and the build prints `BUILD SUCCESS`, exit 0.
Do not accept `BUILD SUCCESS` on its own — count the rows of the Reactor Summary. If there is no Reactor
Summary block at all, you built one module, not three.

Answer: `solution/run.sh` (verified by the author, 3 runs, exit 0 every time).
