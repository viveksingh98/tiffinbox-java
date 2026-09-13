# Unit 26 — Files: Read and Write with java.nio

**What this unit teaches:** Persistence with `Path` and `Files`: write, read, append, and the exception a missing file throws.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1. Run these in order — `SaveCustomers` creates the file the others read.

Run everything from this folder (`cd unit26`), in the order below.

### java SaveCustomers.java

`Files.writeString` creates the file in the working directory.

```console
$ java SaveCustomers.java
Saved customers.csv: true, 34 bytes
```

### java ReadCustomers.java

`Files.readAllLines` and `Files.readString` — note the blank last line from the trailing `\n`.

```console
$ java ReadCustomers.java
2 customers on file
- Ravi,2,120,true
- Meera,1,150,false
Ravi,2,120,true
Meera,1,150,false
```

### java AppendCustomers.java

`StandardOpenOption.APPEND` adds a line instead of replacing the file.

```console
$ java AppendCustomers.java
3 customers on file
Sunil,1,120,true
```

### java BreakFile.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** one letter wrong in the file name (`customer.csv`).

```console
$ java BreakFile.java
Exception in thread "main" java.nio.file.NoSuchFileException: customer.csv
	at java.base/sun.nio.fs.UnixException.translateToIOException(UnixException.java:92)
	at java.base/sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:106)
	at java.base/sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:111)
	at java.base/sun.nio.fs.UnixFileSystemProvider.newFileChannel(UnixFileSystemProvider.java:213)
	at java.base/sun.nio.fs.UnixFileSystemProvider.newByteChannel(UnixFileSystemProvider.java:244)
	at java.base/java.nio.file.Files.newByteChannel(Files.java:357)
	at java.base/java.nio.file.Files.newByteChannel(Files.java:399)
	at java.base/java.nio.file.spi.FileSystemProvider.newInputStream(FileSystemProvider.java:371)
	at java.base/java.nio.file.Files.newInputStream(Files.java:154)
	at java.base/java.nio.file.Files.newBufferedReader(Files.java:2645)
	at java.base/java.nio.file.Files.readAllLines(Files.java:3085)
	at java.base/java.nio.file.Files.readAllLines(Files.java:3122)
	at BreakFile.main(BreakFile.java:2)
```

Exit code: `1` (non-zero — the failure is the point).

### java FixFile.java

The fix: check `Files.exists` (or catch `NoSuchFileException`) first.

```console
$ java FixFile.java
No file yet, starting empty: customer.csv
```

### Notes

- These programs create `customers.csv` in this folder. It is git-ignored; `rm customers.csv` resets the unit.
