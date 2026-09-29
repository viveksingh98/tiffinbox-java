# Exercise — no pin at all

`../after/pom.xml` is TiffinBox as this video leaves it: one property, `<jackson-2-bom.version>2.22.2</jackson-2-bom.version>`,
moves the whole Jackson 2 family. **Delete that line and rebuild clean.** Predict first: a split family again, or one
version? And who chose it?

Run from this folder (`c5-unit03/exercise/`), exactly as written — macOS, bash or zsh:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf my-tiffinbox && rsync -a --exclude target ../after/ my-tiffinbox/
sed '/<jackson-2-bom.version>/d' ../after/pom.xml > my-tiffinbox/pom.xml
(cd my-tiffinbox && mvn -q -Dmaven.repo.local=../../.m2-demo -DskipTests clean package)
ls my-tiffinbox/tiffinbox-web/target/lib | grep '^jackson-' | paste -sd' ' -
```

**Done means:** that last line — the same form as the `jackson` capture in `../receipts.sh` — and you can say who chose
the three versions, and why this is not the split family of the break. Then serve it (the port comes first: TiffinBox's
`main` still reads it from `args[0]`) and hash the seven answers:

```
java -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18540 > my-tiffinbox/serve.log 2>&1 &
until curl -s -o /dev/null http://127.0.0.1:18540/kitchen; do sleep 0.25; done
../../c4-unit31/curlset.sh 18540 | grep ' -> ' | md5 -q
wait
```

`../../.m2-demo` is this unit's own repository, and `../receipts.sh` fills it with everything these commands need; on a
fresh clone run `../receipts.sh` first (it resolves from Maven Central once), or let Maven fetch what is missing. Port
18540 is also one of the receipts' ports, so do not run both at once. Solution in `solution/`.
