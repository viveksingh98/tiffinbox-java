# Exercise — JPA, Hibernate, Spring Data: Three Different Things

**Your turn:** the README's tree has no database driver in it. Run it the way the receipt does, and find H2.

TiffinBox's database driver, H2, is a dependency of `tiffinbox-core`, and `tiffinbox-web` depends on `tiffinbox-core`. The lines
below ask Maven for `tiffinbox-web`'s dependency tree. Run them from this unit's folder (`c7-unit02/`), in bash or in zsh, after
`.m2-demo` is seeded (`../README.md`, "The repository, and the network"): they copy the anchor to `.harness/ex` and ask there, offline,
so the anchor itself is never written to. `/usr/bin/grep` is named in full, because an interactive zsh may alias `grep`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M2="$PWD/.m2-demo"
mkdir -p .harness/ex && rsync -a --delete --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/ex/
cd .harness/ex
mvn -o -B -Dmaven.repo.local="$M2" dependency:tree -pl tiffinbox-web > ../ex-tree.log; echo "exit $?"
/usr/bin/grep -c 'The POM for com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing' ../ex-tree.log
/usr/bin/grep -c 'com.h2database:h2' ../ex-tree.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
exit 0
1
0
```

Maven says `BUILD SUCCESS` (exit 0) — and one WARNING, `The POM for com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing, no dependency
information available`, and a tree with no `com.h2database:h2` in it. `-pl tiffinbox-web` built one module, so Maven looked for
`tiffinbox-core` in the repository instead of the reactor, found no POM there (TiffinBox was never installed), and printed the module
without its dependencies.

**Done** when the last number says `1` and the WARNING count says `0`. Change only the Maven line and the file the last line reads.
The solution, and what it prints, is in `SOLUTION.md`.
