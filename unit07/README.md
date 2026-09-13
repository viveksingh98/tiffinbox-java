# Unit 07 — Strings: Text Done Right

**What this unit teaches:** String is an object with behaviour: four everyday methods, immutability, `equals` vs `==`, and text blocks.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit07`), in the order below.

### java Menu.java

`length`, `toUpperCase`, `substring`, `contains` — and the original string unchanged.

```console
$ java Menu.java
20
COTTAGE CHEESE CURRY
cottage
true
cottage cheese curry
COTTAGE CHEESE CURRY
```

### java MenuCard.java

A text block (`"""`) for the daily card.

```console
$ java MenuCard.java
TiffinBox - Monday
Veg special: cottage cheese curry
Price: 120 per meal
Reply PAUSE to skip today.
```

### java Compare.java

`==` compares identity, `equals` compares text — the classic beginner trap.

```console
$ java Compare.java
veg
veg
false
true
true
```
