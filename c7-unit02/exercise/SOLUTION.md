# Solution — JPA, Hibernate, Spring Data: Three Different Things

Run the tree from the reactor root — the folder of the parent POM — so Maven reads every module of the build, and let each module
write its own tree to a file: `tiffinbox-web/tree.txt` is the one to read. That is the receipt's own tree line. The same lines as the
README's, two of them changed:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M2="$PWD/.m2-demo"
mkdir -p .harness/ex && rsync -a --delete --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/ex/
cd .harness/ex
mvn -o -B -Dmaven.repo.local="$M2" dependency:tree -DoutputFile=tree.txt > ../ex-tree.log; echo "exit $?"
/usr/bin/grep -c 'The POM for com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing' ../ex-tree.log
/usr/bin/grep -c 'com.h2database:h2' tiffinbox-web/tree.txt
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh, in the same shell after the README's lines):

```
exit 0
0
1
```

No WARNING, and H2 is in the tree: `com.h2database:h2:jar:2.5.250:compile`, under `com.tiffinbox:tiffinbox-core`. Broken ≠ solved: the
README's lines find H2 0 times, these find it once.
