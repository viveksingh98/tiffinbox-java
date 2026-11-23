# Course 8, unit 21's exercise check: the store's own REST API, by curl on 127.0.0.1:20608, never the exit of a run. Three readings: the
# ids a match query for veg on name finds; the analyzer the index's mapping names for name's search side (search_analyzer, else
# analyzer, else Elasticsearch's standard); and the tokens that analyzer gives for vegetarian. Solved: exactly the vegetarian box's id,
# 1, and veg among those tokens. Run with bash exercise/check.sh.
J='Content-Type: application/json'; E=http://127.0.0.1:20608
H=$(curl -s --noproxy '*' -H "$J" -X POST "$E/dishes/_search" -d '{"query":{"match":{"name":"veg"}}}' | python3 -I -c 'import json,sys; d=json.load(sys.stdin); i=sorted(h["_id"] for h in d["hits"]["hits"]); print(d["hits"]["total"]["value"], "[" + ", ".join(i) + "]")')
A=$(curl -s --noproxy '*' "$E/dishes/_mapping" | python3 -I -c 'import json,sys; p=json.load(sys.stdin)["dishes"]["mappings"]["properties"]["name"]; print(p.get("search_analyzer", p.get("analyzer", "standard")))')
T=$(curl -s --noproxy '*' -H "$J" -X POST "$E/dishes/_analyze" -d '{"analyzer":"'"$A"'","text":"vegetarian"}' | python3 -I -c 'import json,sys; print("[" + ", ".join(t["token"] for t in json.load(sys.stdin)["tokens"]) + "]")')
case "$H $T" in "1 [1] "*veg[],]*) S=yes ;; *) S=no ;; esac
echo "check: match name veg -> $H · name's search-side analyzer: $A · its tokens for vegetarian: $T · solved: $S"
