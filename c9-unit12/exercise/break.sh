#!/bin/sh
# break.sh TREE - makes the exercise's start on a copy of ../after: version one is retired. One python edit of
# tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java - addSupportedVersions("1.0") becomes addSupportedVersions("2.0")
# (the receipts' harness/mirror/retire.diff, the same line). Nothing else in the tree moves. The existing tests are red on this tree (they
# send the old address): build it with -DskipTests.
[ -n "$1" ] && [ -d "$1" ] || { echo "break.sh TREE"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "break.sh: ../after is unit 12's frozen tree - break a copy of it"; exit 1; }
python3 -I - "$rpath/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java" <<'PY'
import sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read()
a = 'setVersionRequired(false).addSupportedVersions("1.0");'
assert s.count(a) == 1, ("the configurer's supported version", s.count(a))
open(f, "w", encoding="utf-8").write(s.replace(a, a.replace('"1.0"', '"2.0"')))
print('break.sh: TiffinBoxApiVersioning supports "2.0" only - version one is retired')
PY
