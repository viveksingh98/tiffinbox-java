# Course 8, unit 25's exercise check: the lab's own line, read off its log, AND Redis's own answer - redis-cli SCARD on the index set
# for value 240 in the exercise's Redis container - never the exit of a run (the lab exits 0 either way). Solved: the lab called
# findByValue(240) and got 30 orders, AND Redis holds the set kitchen-order:value:240 with 30 ids in it. A "solution" that calls another
# method, or asks for another number, fails here even when it finds thirty. Run with bash exercise/check.sh LOG.
L=${1:?name the lab log}
DH=${DH:-unix://$HOME/.orbstack/run/docker.sock}
C=$(grep -E "^the lab's RValue \(built by RedisRepositoryFactory\): " "$L" | head -1 | sed "s/^the lab's RValue (built by RedisRepositoryFactory): //")
N=$(docker -H "$DH" exec c8u25-ex-redis redis-cli SCARD kitchen-order:value:240 2>&1 | tr -d '\r' | tail -1)
case "$C|$N" in "findByValue(240) -> 30 orders|30") S=yes ;; *) S=no ;; esac
echo "check: the lab's call ${C:-none} · redis-cli SCARD kitchen-order:value:240 $N · solved: $S"
