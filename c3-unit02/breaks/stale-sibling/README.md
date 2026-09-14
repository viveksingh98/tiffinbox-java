# Break it on purpose — `-pl` with no `-am`, building against last week's jar

`-pl` without `-am` does **not** always fail. When a sibling is already installed in the local repository,
`-pl` compiles against that installed jar and prints `BUILD SUCCESS`. Reproduce it:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25 && export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -q install -Dmaven.repo.local="$PWD/.m2-demo"          # Friday: the whole reactor is installed
sed -i '' 's/    VEG(60),/    VEG(999),/' \
    tiffinbox-core/src/main/java/com/tiffinbox/core/MealType.java   # Monday: somebody edits core
mvn -B clean package -pl tiffinbox-kitchen -Dmaven.repo.local="$PWD/.m2-demo"
```
```
5:    VEG(999),
[INFO] BUILD SUCCESS
<repo>/com/tiffinbox/tiffinbox-core/1.0.0/tiffinbox-core-1.0.0.jar
         7: bipush        60
```

Line 1 is the source. Line 2 is the build's verdict. Line 3 is the kitchen's **compile classpath**
(`mvn -B -q dependency:build-classpath -pl tiffinbox-kitchen -Dmdep.outputFile=cp.txt`) — the installed jar,
not the sibling's `target/classes`. Line 4 is `javap -c -p` on that jar: it still says **60**.

Green build, wrong input, no warning. Add `-am` and the same command rebuilds the sibling from source:

```
mvn -B clean package -pl tiffinbox-kitchen -am -Dmaven.repo.local="$PWD/.m2-demo"
javap -c -p -cp tiffinbox-core/target/classes com.tiffinbox.core.MealType | grep -E 'bipush|sipush' | head -1
```
```
[INFO] Reactor Build Order:
[INFO] TiffinBox (reactor demo)                                           [pom]
[INFO] TiffinBox Core                                                     [jar]
[INFO] TiffinBox Kitchen                                                  [jar]
[INFO] BUILD SUCCESS
         7: sipush        999
```

Both captures: 3 runs, byte-identical, exit 0. **Habit: `-pl` and `-am` travel together.**
(Restore the source with `sed -i '' 's/    VEG(999),/    VEG(60),/' …` when you are done.)
