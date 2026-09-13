# Unit 22 — Sorting and Comparators

**What this unit teaches:** Teach Java what "smaller" means: `Comparable` for the natural order, `Comparator` for every other order.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit22`), in the order below.

### java Sorting.java

`Collections.sort`, `reverseOrder`, and sorting an `int[]`.

```console
$ java Sorting.java
[Meera, Ravi, Sunil]
[Sunil, Ravi, Meera]
[3600, 4500, 7200] [7200, 4500, 3600]
```

### java ComparableDemo.java

The class states its own order in `compareTo`.

```console
$ java ComparableDemo.java
Meera 1 meals, bill 4500
Ravi 2 meals, bill 7200
Sunil 1 meals, bill 3600
```

### java Comparators.java

`comparingInt`, `reversed`, `thenComparing` — three orders, one list.

```console
$ java Comparators.java
Sunil 3600 | Meera 4500 | Ravi 7200 | 
Ravi 7200 | Meera 4500 | Sunil 3600 | 
Meera 4500 | Sunil 3600 | Ravi 7200 | 
```

### java BreakSort.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `Collections.sort` on a class that is not `Comparable`.

```console
$ java BreakSort.java
BreakSort.java:6: error: no suitable method found for sort(ArrayList<BreakSort.Customer>)
    Collections.sort(customers);
               ^
    method Collections.<T#1>sort(List<T#1>) is not applicable
      (inference variable T#1 has incompatible bounds
        equality constraints: BreakSort.Customer
        upper bounds: Comparable<? super T#1>)
    method Collections.<T#2>sort(List<T#2>,Comparator<? super T#2>) is not applicable
      (cannot infer type-variable(s) T#2
        (actual and formal argument lists differ in length))
  where T#1,T#2 are type-variables:
    T#1 extends Comparable<? super T#1> declared in method <T#1>sort(List<T#1>)
    T#2 extends Object declared in method <T#2>sort(List<T#2>,Comparator<? super T#2>)
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakNatural.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `Comparator.naturalOrder()` needs a natural order to exist.

```console
$ java BreakNatural.java
BreakNatural.java:6: error: method sort in class ArrayList<E> cannot be applied to given types;
    customers.sort(Comparator.naturalOrder());
             ^
  required: Comparator<? super BreakNatural.Customer>
  found:    Comparator<T#1>
  reason: argument mismatch; inference variable T#2 has incompatible bounds
      upper bounds: Comparable<? super T#2>
      lower bounds: BreakNatural.Customer
  where T#1,E,T#2 are type-variables:
    T#1 extends Comparable<? super T#1>
    E extends Object declared in class ArrayList
    T#2 extends Comparable<? super T#2> declared in method <T#2>naturalOrder()
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).
