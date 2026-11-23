# Course 8, unit 24's exercise check: the lab's own bean list, read off its log, and BOTH stores' own counts - psql in the exercise's
# PostgreSQL container, mongosh in a container with no network on the replica set's unix socket - never the exit of a run (the lab
# catches the exception and exits 0 either way). Solved: JPA's manager and Mongo's, named transactionManager and
# mongoTransactionManager, AND the dish row 1 AND the note 1. Mongo's bean renamed transactionManager prints one manager, rows 0 and
# documents 1 with no exception: it fails here. Run with bash exercise/check.sh LOG.
L=${1:?name the lab log}
DH=${DH:-unix://$HOME/.orbstack/run/docker.sock}
B=$(grep -E "^the lab's transaction managers: " "$L" | head -1 | sed "s/^the lab's transaction managers: //")
R=$(docker -H "$DH" exec c8u24-ex-pg psql -U tiffinbox -d tiffinbox -qAt -c "select count(*) from dish where name = 'Garden Salad Bowl'" 2>&1 | tail -1)
D=$(docker -H "$DH" run --rm --label c8u24.ex=1 --network none --volumes-from c8u24-ex-rs -e GLIBC_TUNABLES=glibc.pthread.rseq=1 --entrypoint mongosh mongo:8 --quiet 'mongodb://%2Fdata%2Fdb%2Fmongodb-27017.sock/tiffinbox?directConnection=true' --eval 'print(db.lab_notes.countDocuments({name: "Garden Salad Bowl"}))' 2>&1 | tail -1)
case "$B|$R|$D" in "[transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]|1|1") S=yes ;; *) S=no ;; esac
echo "check: the bean list $B · rows (psql) $R · documents (mongosh, no network) $D · solved: $S"
