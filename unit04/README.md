# Unit 04 — How Java Actually Runs: Source, Bytecode, JVM

**What this unit teaches:** Follow one line of code from source to javac to bytecode to the JVM, and read the bytecode yourself.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1. `javac` and `javap` ship with the same JDK.

Run everything from this folder (`cd unit04`), in the order below.

### java Hello.java

The source launcher: compile and run in one step, nothing left on disk.

```console
$ java Hello.java
Hello, TiffinBox!
```

### javac Hello.java

Compile only — `javac` writes the bytecode file next to the source.

```console
$ javac Hello.java && ls Hello.class
Hello.class
```

### java Hello

Run the *class* (no `.java`): the JVM loads `Hello.class`.

```console
$ java Hello
Hello, TiffinBox!
```

### javap -c Hello

Disassemble the bytecode — this is what the JVM actually executes.

```console
$ javap -c Hello
Compiled from "Hello.java"
public class Hello {
  public Hello();
    Code:
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return

  public static void main(java.lang.String[]);
    Code:
         0: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
         3: ldc           #13                 // String Hello, TiffinBox!
         5: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
         8: return
}
```

### Notes

- Clean up the class file when you are done: `rm Hello.class` (it is git-ignored anyway).
