#!/bin/sh
# break.sh TREE - makes the exercise's start on a copy of ../after: one python edit of the shipped REST Docs test,
# tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java - a fifth documented member, nickname, which TiffinBox
# never sends, joins the test's responseFields. Nothing else in the tree moves.
[ -n "$1" ] && [ -d "$1" ] || { echo "break.sh TREE"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "break.sh: ../after is unit 11's frozen tree - break a copy of it"; exit 1; }
python3 -I - "$rpath/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java" <<'PY'
import sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read()
a = '                       fieldWithPath("mealType").description("VEG, NON_VEG or VEGAN"))));\n'
b = '                       fieldWithPath("mealType").description("VEG, NON_VEG or VEGAN"),\n                       fieldWithPath("nickname").description("a field TiffinBox never sends"))));\n'
assert s.count(a) == 1, ("the test's last documented member", s.count(a))
open(f, "w", encoding="utf-8").write(s.replace(a, b))
print('break.sh: TiffinBoxRestDocsTest documents fieldWithPath("nickname") - a field TiffinBox never sends')
PY
