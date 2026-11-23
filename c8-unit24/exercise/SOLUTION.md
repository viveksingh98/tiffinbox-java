# Exercise - unit 24: one solution

Declare JPA's manager yourself, beside Mongo's, in `Managers` - the line Boot's `JpaBaseConfiguration` would have made, named the way
Boot and every JPA repository look for it, and `@Primary`, so the plain `@Transactional` method that names no manager runs under it:

`@Bean @Primary JpaTransactionManager transactionManager(EntityManagerFactory emf) { return new JpaTransactionManager(emf); }`

The lines are the README's with one changed: `Lab24.java` is copied with that line in place of the comment that says JPA's manager is
not declared here.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; mkdir -p "$EX"; rm -rf "$EX/run.log" "$EX/cls"; [ -d "$EX/tb" ] || rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
[ -f "$EX/x/tiffinbox-web-1.0.0.jar" ] || { (cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; }; echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
perl -pe 's#^ *// JPA.s manager is not declared here$#        \@Bean \@Primary JpaTransactionManager transactionManager(EntityManagerFactory emf) { return new JpaTransactionManager(emf); }#' exercise/Lab24.java > "$EX/Lab24.java"
docker -H "$DH" run -d --name c8u24-ex-rs --hostname c8u24-ex-rs -p 127.0.0.1:20635:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo:8 --replSet rs0 --unixSocketPrefix /data/db --bind_ip_all > /dev/null
docker -H "$DH" run -d --name c8u24-ex-pg -p 127.0.0.1:20636:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust postgres:18-alpine > /dev/null
i=0; until docker -H "$DH" exec c8u24-ex-pg pg_isready -U tiffinbox -h 127.0.0.1 -q || [ $i -ge 240 ]; do sleep 0.5; i=$((i + 1)); done
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' javac -nowarn -d "$EX/cls" -cp "$EX/x/lib/*" "$EX/Lab24.java"
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/cls:$EX/x/lib/*" lab24.Lab24 init > "$EX/init.log" 2>&1; grep "^the lab's hello" "$EX/init.log"
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/cls:$EX/x/lib/*" lab24.Lab24 run > "$EX/run.log" 2>&1; grep "^the lab's" "$EX/run.log"
bash exercise/check.sh "$EX/run.log"
docker -H "$DH" rm -fv c8u24-ex-rs c8u24-ex-pg > /dev/null
```

What it prints:

```
built: 1 jar
the lab's hello: isWritablePrimary true · setName rs0 · members 1
the lab's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]
the lab's plain call: caller saw no exception
the lab's plain: rows 1 · documents 1
check: the bean list [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager] · rows (psql) 1 · documents (mongosh, no network) 1 · solved: yes
```

Two managers, each named: the plain call runs under JPA's (`@Primary`), the row commits with JPA's transaction, and the note is
inserted outside it - it is MongoDB's write, under no manager of its own here. One row and one document, two writes and two stores:
the check passes. The other name is refused: with Mongo's bean renamed `transactionManager`, the row's save runs under Mongo's manager and
writes no row. The caller sees no exception either way (README.md, and this unit's `mtmnamed`).
