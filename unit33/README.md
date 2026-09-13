# Unit 33 — Packages, Imports and Project Structure

**What this unit teaches:** Packages are folders with a name, `src/main/java` is the standard layout, and a class is run by its full name.

**You need:** JDK 25 (`java.lang.IO` is an ordinary class, JEP 512; module import declarations, JEP 511). Verified on JDK 25.0.4.1. Packaged sources cannot use the single-file launcher — compile with `-d` first.

Run everything from this folder (`cd unit33`), in the order below.

### javac -d out src/main/java/com/tiffinbox/*.java

Compile the package into `out/` — the folders under `out` ARE the package.

```console
$ javac -d out src/main/java/com/tiffinbox/*.java && ls out/com/tiffinbox
Billing.class
Main.class
ModuleImports.class
```

### java -cp out com.tiffinbox.Main

Run by full name, standing at the root of the class tree.

```console
$ java -cp out com.tiffinbox.Main
3 customers on file
Ravi pays 7200
```

### java -cp out com.tiffinbox.ModuleImports

JDK 25's `import module java.base;` (JEP 511).

```console
$ java -cp out com.tiffinbox.ModuleImports
[Ravi, Meera, Sunil] 2026-09-01
```

### cd out/com/tiffinbox — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** standing inside the package folder and using the short name.

```console
$ cd out/com/tiffinbox && java Main
Error: Could not find or load main class Main
Caused by: java.lang.NoClassDefFoundError: Main (wrong name: com/tiffinbox/Main)
```

Exit code: `1` (non-zero — the failure is the point).

### Notes

- `src/test/java/com/tiffinbox/` is empty on purpose — Unit 35 puts `BillingTest.java` there.
- Quick check without `-d`: `java src/main/java/com/tiffinbox/Main.java` (the source launcher compiles the siblings, JEP 458).
- `out/` is git-ignored; `rm -rf out` resets the unit.
