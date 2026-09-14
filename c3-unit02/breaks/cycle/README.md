# Break it on purpose — the cycle

Add **one dependency** to `tiffinbox-core/pom.xml` (it is in `core-pom-with-cycle.xml` here, ready to copy):

```
  <dependencies>
    <dependency>
      <groupId>com.tiffinbox</groupId>
      <artifactId>tiffinbox-web</artifactId>
      <version>1.0.0</version>
    </dependency>
  </dependencies>
```

Then, from `c3-unit02/`:

```
mvn -B clean package -Dmaven.repo.local="$PWD/.m2-demo"
```
```
[INFO] Scanning for projects...
[ERROR] The projects in the reactor contain a cyclic reference: Edge between 'Vertex{label='com.tiffinbox:tiffinbox-core:1.0.0'}' and 'Vertex{label='com.tiffinbox:tiffinbox-web:1.0.0'}' introduces to cycle in the graph com.tiffinbox:tiffinbox-web:1.0.0 --> com.tiffinbox:tiffinbox-kitchen:1.0.0 --> com.tiffinbox:tiffinbox-core:1.0.0 --> com.tiffinbox:tiffinbox-web:1.0.0 -> [Help 1]
class files written: 0
```

exit 1, 3 runs, byte-identical.

**The proof is the last line, not the error.** `find . -name '*.class' | wc -l` answers **0**, and no
`target/` directory exists anywhere in the tree. The build died at `Scanning for projects...` — the reactor
sorts the module graph *before* it runs a single goal, and a graph with a loop in it cannot be sorted.
