# Unit 27 — Parsing Data: CSV to Objects

**What this unit teaches:** Turn text back into typed values and objects: `split(",")`, `Integer.parseInt`, and one bad row that stops everything.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1. Each program writes the CSV it reads, so they are safe to run in any order.

Run everything from this folder (`cd unit27`), in the order below.

### java ParseOne.java

One line split into four fields and parsed into a record.

```console
$ java ParseOne.java
4 parts, first: Ravi
Customer[name=Ravi, mealsPerDay=2, pricePerMeal=120, isVeg=true]
Monthly: 7200
21
3
```

### java LoadCustomers.java

A whole file to a `List<Customer>`, skipping the header.

```console
$ java LoadCustomers.java
Ravi: 7200
Meera: 4500
Sunil: 3600
3 customers, 15300 a month
```

### java RoundTrip.java

Load, add, save — text to objects and back to text.

```console
$ java RoundTrip.java
Loaded 2
Saved 3
name,mealsPerDay,pricePerMeal,isVeg
Ravi,2,120,true
Meera,1,150,false
Sunil,1,120,true
```

### java BreakParse.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `"two"` where a number belongs kills the whole load.

```console
$ java BreakParse.java
Exception in thread "main" java.lang.NumberFormatException: For input string: "two"
	at java.base/java.lang.NumberFormatException.forInputString(NumberFormatException.java:67)
	at java.base/java.lang.Integer.parseInt(Integer.java:565)
	at java.base/java.lang.Integer.parseInt(Integer.java:662)
	at BreakParse.parse(BreakParse.java:17)
	at BreakParse.load(BreakParse.java:11)
	at BreakParse.main(BreakParse.java:4)
```

Exit code: `1` (non-zero — the failure is the point).

### java FixParse.java

The fix: catch per line, report it, keep the good rows.

```console
$ java FixParse.java
Skipped line 4: For input string: "two" in 'Sunil,two,120,true'
2 customers loaded
```

### Notes

- These programs create `customers.csv` in this folder. It is git-ignored; `rm customers.csv` resets the unit.
