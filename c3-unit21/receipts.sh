#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh query      run one block
#
# The four rules this section works to:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE - appended into the .out before it is hashed.
#   2. A BLOCK THAT CANNOT MEASURE MUST NOT PRINT - die() instead of a confident zero.
#   3. EVERY BLOCK MEASURES ITS OWN RUN - nothing is read back from an earlier one.
#   4. A LOG LINE CARRIES A CLOCK - mask_time() before anything is hashed.
#
# This unit's own rule: BOTH ENCODINGS COME FROM ONE RUN. logback.xml attaches the text
# appender and the JSON appender to the same root, so no event can be in one file and not
# the other. Two runs would let any difference be blamed on the runs.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }
hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }

# Two clocks to mask here, not one: the text layout's HH:mm:ss.SSS and the JSON encoder's
# ISO-8601 @timestamp, which also carries this machine's UTC offset.
mask_time() { sed -E -e 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /' \
                     -e 's/"@timestamp":"[^"]*"/"@timestamp":"<time>"/' \
                     -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                     -e "s#${PWD}/#<project>/#g" \
                     -e 's#[^ ]*/c3-unit21/#<project>/#g' \
                     -e 's#/Users/[^/]*/#<home>/#g'; }

TEXT=target/logs/kitchen.log
JSON=target/logs/kitchen.json

# One run, both files. Every block that needs the logs calls this; none reads an old one.
produce() {
  rm -rf target/logs
  "${MVN[@]}" -q compile exec:exec > .r-run.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "the run exited $rc"
  [ -s "$TEXT" ] || die "no $TEXT - the TEXT appender wrote nothing"
  [ -s "$JSON" ] || die "no $JSON - the JSON appender wrote nothing"
  # every JSON line must parse, or nothing below is a measurement
  jq -e . "$JSON" > /dev/null 2>&1 || die "$JSON is not one valid JSON object per line"
  return 0
}

# ------------------------------------------------------------------- both ----
run_both() {
  block "both - the same events, encoded twice, in one run"
  produce; local rc=$?
  { printf '%s\n' "$TEXT"; mask_time < "$TEXT"
    printf '%s\n' "$JSON"; mask_time < "$JSON" | cut -c1-120 | sed 's/$/ .../'
  } > .r-both.out

  local tl je extra
  tl=$(grep -c . "$TEXT")
  je=$(jq -s 'length' "$JSON")
  extra=$(( tl - je ))
  [ "$je" -gt 0 ] || die "the JSON log holds no events"
  [ "$extra" -gt 0 ] || die "the text log has $tl line(s) for $je event(s) - the stack trace did not span lines"
  { printf 'lines in the text log ....... %d\n' "$tl"
    printf 'JSON objects in the JSON log  %d\n' "$je"
    printf 'the difference ............. %d, and every one of them is a stack-trace line\n' "$extra"
    printf 'stack-trace lines in the text log: %d\n' "$(grep -cE '^(java\.|\s+at )' "$TEXT")"
    printf 'the JSON panel above is cut at 120 characters - every line of it is longer\n'
  } >> .r-both.out
  cat .r-both.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-both.out)" "$rc"
}

# ------------------------------------------------------------------ query ----
# The question: every event for order B-9082 at WARN or above.
run_query() {
  block "query - one question, asked of both encodings"
  produce; local rc=$?

  local jqq grepq
  jqq='select(.orderId=="B-9082" and .level_value>=30000)'
  grepq="grep B-9082 $TEXT | grep -E 'WARN|ERROR'"

  { printf 'the question: every event for order B-9082 at WARN or above\n'
    printf '\njq -c %s\n' "'$jqq'"
    jq -c "$jqq" "$JSON" | mask_time | cut -c1-120 | sed 's/$/ .../'
    printf '\n%s\n' "$grepq"
    grep 'B-9082' "$TEXT" | grep -E 'WARN|ERROR' | mask_time
  } > .r-query.out

  local jn gn false_pos trace_lost
  jn=$(jq -c "$jqq" "$JSON" | grep -c .)
  gn=$(grep 'B-9082' "$TEXT" | grep -cE 'WARN|ERROR')
  # a grep hit whose OWN orderId field is not B-9082 is a false positive, and the JSON is
  # what settles which those are - read out, never assumed
  # Which hits are false is decided by the ID FIELD of the line, at its position in the
  # layout (time, level, logger, id), not by pattern-matching for a particular order.
  false_pos=$(grep 'B-9082' "$TEXT" | grep -E 'WARN|ERROR' \
              | awk '$4 != "B-9082" { c++ } END { print c+0 }')
  trace_lost=$(grep -cE '^(java\.|\s+at )' "$TEXT")
  [ "$jn" -gt 0 ] || die "the jq query matched nothing - there is no comparison to make"
  [ "$gn" -gt "$jn" ] || die "grep returned $gn against jq's $jn; this run does not show the gap"
  [ "$false_pos" -gt 0 ] || die "no false positive in the grep answer - the trap event is missing"

  { printf '\njq matched ................. %d event(s)\n' "$jn"
    printf 'grep matched ............... %d line(s)\n' "$gn"
    printf "of those, belonging to a DIFFERENT order: %d\n" "$false_pos"
    printf 'stack-trace lines the grep dropped: %d (they carry no level and no id)\n' "$trace_lost"
    printf 'the grep answer is wrong in both directions at once: it includes %d line(s) that are not\n' "$false_pos"
    printf "B-9082's, and excludes %d line(s) that are\n" "$trace_lost"
  } >> .r-query.out
  cat .r-query.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-query.out)" "$rc"
}

# ----------------------------------------------------------------- fields ----
run_fields() {
  block "fields - an MDC entry is a key, and an absent one is an absent key"
  produce; local rc=$?
  { printf 'keys on every object, in order of appearance:\n'
    jq -r 'keys_unsorted | join(" ")' "$JSON" | sort -u | sed 's/^/  /'
    printf '\norderId, per event:\n'
    jq -r '[.level, (.orderId // "(absent)"), .message] | @tsv' "$JSON" \
      | awk -F'\t' '{printf "  %-6s %-10s %s\n", $1, $2, substr($3,1,52)}'
  } > .r-fields.out

  local total with without puts
  total=$(jq -s 'length' "$JSON")
  with=$(jq -s '[.[] | select(has("orderId"))] | length' "$JSON")
  without=$(jq -s '[.[] | select(has("orderId") | not)] | length' "$JSON")
  puts=$(grep -vE '^[[:space:]]*(\*|//|/\*)' src/main/java/com/tiffinbox/kitchen/KitchenEvents.java \
         | sed -E 's#[[:space:]]*//.*$##' | grep -c 'MDC.put(')
  [ "$total" -eq $(( with + without )) ] || die "the two groups do not add up to $total events"
  [ "$without" -gt 0 ] || die "every event carries an orderId - the absent-field case is missing"
  [ "$puts" -gt 0 ] || die "no MDC.put() in KitchenEvents.java"
  local jsoncfg
  jsoncfg=$(sed -n '/<appender name="JSON"/,/<\/appender>/p' src/main/resources/logback.xml | grep -c 'orderId')
  [ "$jsoncfg" -eq 0 ] || die "the JSON appender names orderId $jsoncfg time(s); the lesson is that it needs no configuration"
  { printf '\nevents: %d ; carrying an orderId key: %d ; with no such key at all: %d\n' "$total" "$with" "$without"
    printf 'MDC.put() calls in the source: %d\n' "$puts"
    printf 'times orderId is named inside the JSON appender element: %d\n' \
      "$(sed -n '/<appender name="JSON"/,/<\/appender>/p' src/main/resources/logback.xml | grep -c 'orderId')"
    printf 'times orderId is named inside the TEXT appender element: %d  (%%X{orderId:-}, the layout token)\n' \
      "$(sed -n '/<appender name="TEXT"/,/<\/appender>/p' src/main/resources/logback.xml | grep -c 'orderId')"
    printf 'an absent MDC entry is an ABSENT KEY, not an empty string - jq has(...) can ask; a grep cannot\n'
  } >> .r-fields.out
  cat .r-fields.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-fields.out)" "$rc"
}

# --------------------------------------------------------------- truncate ----
# The text layout's own delimiter, inside a message.
run_truncate() {
  block "truncate - the delimiter is not yours alone"
  produce; local rc=$?
  local target text_msg json_msg
  target='kitchen is behind'
  text_msg=$(grep -F "$target" "$TEXT" | head -1 | awk -F' - ' '{print $2}')
  json_msg=$(jq -r --arg t "$target" 'select(.message | startswith($t)) | .message' "$JSON")
  [ -n "$text_msg" ] && [ -n "$json_msg" ] || die "the delimiter-bearing event is not in one of the two logs"

  { printf 'the layout is  ... %%X{orderId:-} - %%msg%%n  , so " - " separates the id from the message\n'
    printf 'the message logged, read out of the JSON: %s\n' "$json_msg"
    printf 'the same message, cut out of the text log on that separator: %s\n' "$text_msg"
  } > .r-truncate.out

  local jl tlen
  jl=${#json_msg}; tlen=${#text_msg}
  [ "$tlen" -lt "$jl" ] || die "the text extraction lost nothing; this message no longer carries the delimiter"
  { printf 'characters logged: %d ; characters the split returned: %d ; lost: %d\n' "$jl" "$tlen" "$(( jl - tlen ))"
    printf 'the two agree: no\n'
    printf 'nothing is wrong with the message. The text format has no way to say where a field ends.\n'
  } >> .r-truncate.out
  cat .r-truncate.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-truncate.out)" "$rc"
}

# ------------------------------------------------------------------- cost ----
# The honest other half: what structure costs.
run_cost() {
  block "cost - what the structure costs, in jars and in characters"
  produce > /dev/null
  "${MVN[@]}" dependency:tree > .r-t.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "dependency:tree exited $rc"

  local rows
  rows=$(grep -E '^\[INFO\] ([+\\| ]+[-\\+] |com\.tiffinbox:)' .r-t.raw | sed 's/^\[INFO\] //')
  [ -n "$rows" ] || die "no tree rows matched the filter"

  { printf '%s\n' "$rows"
  } > .r-cost.out

  local jars j3 j2 tchars jchars ev
  jars=$(printf '%s\n' "$rows" | grep -cE 'jackson')
  j3=$(printf '%s\n' "$rows" | grep -cE 'tools\.jackson')
  j2=$(printf '%s\n' "$rows" | grep -cE 'com\.fasterxml\.jackson')
  ev=$(jq -s 'length' "$JSON")
  tchars=$(( $(wc -c < "$TEXT") / ev ))
  jchars=$(( $(wc -c < "$JSON") / ev ))
  [ "$jars" -gt 0 ] || die "no jackson row in the tree - the encoder's cost is not visible"
  [ "$j3" -gt 0 ] && [ "$j2" -gt 0 ] || die "expected both jackson groupIds; found $j3 / $j2"
  [ "$jchars" -gt "$tchars" ] || die "the JSON log is not wider than the text one; the trade-off is inverted"

  { printf '\njackson rows the encoder brought in: %d\n' "$jars"
    printf '  under tools.jackson.* (Jackson 3) ......... %d\n' "$j3"
    printf '  under com.fasterxml.jackson.* (Jackson 2) . %d  <- the annotations, still on the old groupId\n' "$j2"
    printf 'so a project already on Jackson 2 gets Jackson 3 BESIDE it, not in a fight with it\n'
    printf 'bytes per event: text %d, JSON %d (%d events)\n' "$tchars" "$jchars" "$ev"
    printf 'that is the trade: %d extra bytes an event, and a field a machine can name\n' "$(( jchars - tchars ))"
  } >> .r-cost.out
  cat .r-cost.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-cost.out)" "$rc"
}

# --------------------------------------------------------------- solution ----
run_solution() {
  block "solution - the exercise answer, run"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  ( cd .sol && "${MVN[@]}" -q compile exec:exec ) > .r-s0.raw 2>&1; local rc0=$?
  [ "$rc0" -eq 0 ] || die "the untouched exercise exited $rc0"
  [ -s .sol/target/logs/kitchen.json ] || die "the untouched exercise wrote no JSON log"
  # BOTH halves of the start state's row are measured on the start state's own run. This
  # used to print $q0 over $ev1 - the ANSWER's event total - as the start state's
  # denominator, a number that was never measured for that row and is right today only
  # because both runs happen to produce the same number of events.
  local q0 ev0
  q0=$(jq -c 'select(.customer=="Bela")' .sol/target/logs/kitchen.json 2>/dev/null | grep -c . || true)
  ev0=$(jq -s 'length' .sol/target/logs/kitchen.json)
  [ "$q0" -eq 0 ] || die "the untouched exercise already answers the query ($q0 hit(s)) - it is not a start state"
  [ "$ev0" -gt 0 ] || die "the untouched exercise produced no events"

  cp exercise/solution/KitchenEvents.java .sol/src/main/java/com/tiffinbox/kitchen/KitchenEvents.java
  ( cd .sol && "${MVN[@]}" -q compile exec:exec ) > .r-s1.raw 2>&1; local rc1=$?
  [ "$rc1" -eq 0 ] || die "the answer exited $rc1"
  local q1 ev1 keys
  q1=$(jq -c 'select(.customer=="Bela")' .sol/target/logs/kitchen.json | grep -c .)
  ev1=$(jq -s 'length' .sol/target/logs/kitchen.json)
  keys=$(jq -r 'select(.customer) | keys_unsorted | join(" ")' .sol/target/logs/kitchen.json | head -1)
  [ "$q1" -gt 0 ] || die "the answer still does not put customer in the event"
  [ "$ev1" -gt 0 ] || die "the answer produced no events"

  { printf 'start state: jq select(.customer=="Bela") matched %d of %d event(s)\n' "$q0" "$ev0"
    printf 'answer:      jq select(.customer=="Bela") matched %d of %d event(s)\n' "$q1" "$ev1"
    printf 'keys on an event that carries the new field:\n  %s\n' "$keys"
    jq -r 'select(.customer=="Bela") | [.level, .orderId, .customer, .message] | @tsv' .sol/target/logs/kitchen.json \
      | awk -F'\t' '{printf "  %-6s %-8s %-6s %s\n", $1, $2, $3, substr($4,1,44)}'
  } > .r-solution.out
  cat .r-solution.out
  printf 'md5 %s  exit %d then %d\n' "$(hash_of .r-solution.out)" "$rc0" "$rc1"
  rm -rf .sol
}

# ---------------------------------------------------------------- offline ----
run_offline() {
  block "offline - the contract's 1c receipt"
  "${MVN[@]}" test > /dev/null 2>&1 || die "the warm-up build failed; there is nothing to go offline with"
  "${MVN[@]}" -o test > .r-o.raw 2>&1; local rc=$?
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-o.raw | mask_time > .r-offline.out
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc"
  grep -q 'BUILD SUCCESS' .r-offline.out || die "no BUILD SUCCESS in the offline run"
  printf 'offline: yes (-o), after one warm build of the same lifecycle\n' >> .r-offline.out
  cat .r-offline.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-offline.out)" "$rc"
}

command -v jq > /dev/null || { printf 'jq is not on the PATH; every query block needs it.\n' >&2; exit 2; }

ALL=(both query fields truncate cost solution offline)
if [ $# -eq 0 ]; then set -- "${ALL[@]}"; fi
for b in "$@"; do
  case "$b" in
    both|query|fields|truncate|cost|solution|offline) "run_$b" ;;
    *) printf 'unknown block: %s\nblocks: %s\n' "$b" "${ALL[*]}" >&2; exit 2 ;;
  esac
done
printf '\n'
