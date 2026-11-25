#!/bin/sh
# apply.sh TREE - the receipt's solution, made on the broken copy: the nickname line removed from the test's responseFields, nothing
# else. HOW changes it for the receipt's refused variants: delall (the whole responseFields(...) removed), optional (nickname kept,
# documented .optional()), disabled (the test marked @Disabled), handsnippet (nickname kept; a hand-written response-fields.adoc put
# under target/ - clean writes it away).
[ -n "$1" ] && [ -d "$1" ] || { echo "apply.sh TREE"; exit 1; }
rpath=$(cd "$1" && pwd); how=${HOW:-solution}
python3 -I - "$rpath" "$how" <<'PY'
import os, posixpath as pp, sys
tree, how = sys.argv[1:3]
f = pp.join(tree, "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java"); s = open(f, encoding="utf-8").read()
nick = ',\n                       fieldWithPath("nickname").description("a field TiffinBox never sends"))));\n'
assert s.count(nick) == 1, ("the broken tree's nickname line", s.count(nick))
if how == "solution":
    s = s.replace(nick, ')));\n')
elif how == "delall":
    i = s.index(',\n                   responseFields('); j = s.index(nick) + len(nick)
    s = s[:i] + '));\n' + s[j:]
elif how == "optional":
    s = s.replace(nick, ',\n                       fieldWithPath("nickname").description("a field TiffinBox never sends").optional())));\n')
elif how == "disabled":
    s = s.replace("    @Test\n    void thePublicReadIsDocumented()", "    @org.junit.jupiter.api.Disabled\n    @Test\n    void thePublicReadIsDocumented()")
elif how == "handsnippet":
    d = pp.join(tree, "tiffinbox-web/target/generated-snippets/customer-read"); os.makedirs(d, exist_ok=True)
    open(pp.join(d, "response-fields.adoc"), "w").write("|===\n|Path|Type|Description\n\n|`name`\n|`String`\n|the customer's name\n|===\n")
else:
    sys.exit("apply.sh: HOW must be solution, delall, optional, disabled or handsnippet")
open(f, "w", encoding="utf-8").write(s)
print("apply.sh (%s): done" % how)
PY
