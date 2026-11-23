# Exercise - unit 24: the row that Mongo's manager refused

**Your turn:** adding Mongo's transaction manager made the row's save fail, no bean named transactionManager. Bring JPA's manager back beside it.

This exercise needs Docker and two containers of its own: a MongoDB that is a single-node replica set (Mongo's transaction manager
needs one - Part A's finding) on `127.0.0.1:20635`, and a PostgreSQL on `127.0.0.1:20636`, both by the tags the course measured
(`mongo:8` and `postgres:18-alpine`, at the digests `../c8-tiffinbox/compose.yaml` names). The PostgreSQL container trusts every
connection to it, with no password: it is published on the loopback address alone and removed at the end. The lines below build
TiffinBox's jar from `after/`, offline, from this unit's `.m2-demo` - for its libraries and for the shipped `DishEntity` - and compile
`Lab24.java` against them. `Lab24` starts a small Spring Boot context of its own: Boot's JPA and MongoDB auto-configurations, the
anchor's migrations by Boot's Flyway (the dish table and its ten rows), and its class `Managers`, which declares
`MongoTransactionManager` - and nothing for JPA. Its `init` makes the MongoDB container a replica set through the driver (one member,
named by the host name `localhost` inside the container; the lab's address is one seed with no `replicaSet=` option); its `run` calls one plain `@Transactional` method that saves a dish row through
`DishEntityRepository` and inserts a note into the collection `lab_notes`, then counts both by the dish's name. Run the lines from
`c8-unit24/`, in bash or zsh (the first line points at JDK 25 and at the docker socket on the author's Mac - point them at yours; on a
machine without the images, `docker -H "$DH" run` pulls them; a second run reuses the jar the first built under `.harness/ex` - remove
that folder to build it again):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; mkdir -p "$EX"; rm -rf "$EX/run.log" "$EX/cls"; [ -d "$EX/tb" ] || rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
[ -f "$EX/x/tiffinbox-web-1.0.0.jar" ] || { (cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; }; echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
cp exercise/Lab24.java "$EX/Lab24.java"
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
the lab's transaction managers: [mongoTransactionManager] -> [MongoTransactionManager]
the lab's plain call: caller caught NoSuchBeanDefinitionException: No bean named 'transactionManager' available: No matching TransactionManager bean found for qualifier 'transactionManager' - neither qualifier match nor bean name match!
the lab's plain: rows 0 · documents 0
check: the bean list [mongoTransactionManager] -> [MongoTransactionManager] · rows (psql) 0 · documents (mongosh, no network) 0 · solved: no
```

The plain `@Transactional` method names no manager, so Spring looks for the bean named `transactionManager`; the row's repository
asks for the same name. With `MongoTransactionManager` declared, Boot's own `JpaTransactionManager` is not made (its `@Bean` is
`@ConditionalOnMissingBean(TransactionManager.class)` - this unit's `jars`), and the only manager is Mongo's, named
`mongoTransactionManager`: the call is refused before either write, rows 0 and documents 0. The check is `exercise/check.sh`: the lab's
own bean list, and both stores' own counts - psql in the PostgreSQL container, and mongosh in a container with no network on the
replica set's socket - never the exit of the run (the lab catches the exception and exits 0 either way). Make the same lines print the
two managers, `[transactionManager, mongoTransactionManager]`, and `rows 1 · documents 1` with `solved: yes` - `SOLUTION.md` shows one
way. Renaming Mongo's bean to `transactionManager` fails the check: the lab then prints one manager, `[transactionManager] ->
[MongoTransactionManager]`, and the call returns with no exception - rows 0 and documents 1. The row's save wrote nothing under a
manager that is not JPA's, and nothing said so; the receipt runs that rename three times and the check refuses it each time.
