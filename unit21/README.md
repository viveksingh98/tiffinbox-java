# Unit 21 — Generics: Why List<String> Not Just List

**What this unit teaches:** The angle brackets get their name: type safety at compile time, raw types, bounds and generic methods.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit21`), in the order below.

### java Generics.java

A generic `Box<T>`, a bounded `<T extends Comparable<T>>` method and a wildcard parameter.

```console
$ java Generics.java
Ravi
0
7200
Sunil
```

### java BreakRaw.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a raw `List` hands back `Object`.

```console
$ java BreakRaw.java
BreakRaw.java:3: warning: [unchecked] unchecked call to add(E) as a member of the raw type List
    names.add("Ravi");
             ^
  where E is a type-variable:
    E extends Object declared in interface List
BreakRaw.java:4: error: incompatible types: Object cannot be converted to String
    String first = names.get(0);
                            ^
1 error
1 warning
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakTyped.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** with `<String>` the compiler refuses the wrong type.

```console
$ java BreakTyped.java
BreakTyped.java:4: error: no suitable method found for add(int)
    names.add(42);
         ^
    method List.add(String) is not applicable
      (argument mismatch; int cannot be converted to String)
    method List.add(int,String) is not applicable
      (actual and formal argument lists differ in length)
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakMax.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a bound the argument does not satisfy.

```console
$ java BreakMax.java
BreakMax.java:4: error: method max in class BreakMax cannot be applied to given types;
    IO.println(max(customers));
               ^
  required: List<T>
  found:    ArrayList<Customer>
  reason: inference variable T has incompatible bounds
    equality constraints: Customer
    upper bounds: Comparable<T>
  where T is a type-variable:
    T extends Comparable<T> declared in method <T>max(List<T>)
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java RawCrash.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a raw list compiles with warnings and then blows up at run time.

```console
$ java RawCrash.java
4
RawCrash.java:3: warning: [unchecked] unchecked call to add(E) as a member of the raw type List
    names.add("Ravi");
             ^
  where E is a type-variable:
    E extends Object declared in interface List
RawCrash.java:4: warning: [unchecked] unchecked call to add(E) as a member of the raw type List
    names.add(42);
             ^
  where E is a type-variable:
    E extends Object declared in interface List
2 warnings
Exception in thread "main" java.lang.ClassCastException: class java.lang.Integer cannot be cast to class java.lang.String (java.lang.Integer and java.lang.String are in module java.base of loader 'bootstrap')
	at RawCrash.main(RawCrash.java:6)
```

Exit code: `1` (non-zero — the failure is the point).
