#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh casebug    run one block
#
# WHAT THIS UNIT CAN AND CANNOT PROVE, SAID FIRST BECAUSE IT DECIDES THE WHOLE FILE.
#
#   A GitHub Actions run happens on somebody else's machine, minutes after you ask for it,
#   and it costs money once the repository is private. It cannot be a capture. So this file
#   does NOT pretend to run one. What it does instead is run, locally, every command the
#   workflow runs - the same Maven goals on the same project on both JDKs of the matrix -
#   and prove the one thing a CI unit is really about: that a green build is not evidence.
#
#   `norun` is the block that says the quiet part out loud. It asks whether a run log exists
#   (`gh run list`), records the answer, and refuses to fabricate one. What it HASHES is only
#   the half of that answer which is about the REPOSITORY - no workflow installed, no runs to
#   list, true in every clone of it. Whether `gh` is installed and logged in is about your
#   Mac, so those two lines are printed outside the capture and cannot move the md5.
#
# THE BUG THIS UNIT IS BUILT ON.
#
#   src/main/resources/Menu.json has a capital M. MenuLoader asks for "/menu.json". On this
#   Mac the default volume is case-insensitive, so `mvn verify` is green. `casebug` runs the
#   same classes from three places and gets two different answers.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

JDK25=/opt/homebrew/opt/openjdk@25
JDK26=/opt/homebrew/opt/openjdk@26
REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")
WF=workflows/build.yml
JAR=target/tiffinbox-core-1.0.0.jar
CSVOL=TiffinBoxCaseSensitive
CSIMG="$PWD/.r-cs.dmg"

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }
hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }

mask() { sed -E -e "s#${PWD}/#<project>/#g" -e 's#[^ ]*/c3-unit25/#<project>/#g' \
                -e 's#/Volumes/'"$CSVOL"'#<case-sensitive volume>#g' \
                -e 's#/Users/[^/]*/#<home>/#g' \
                -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//'; }


# EVERY CUT CARRIES ITS COUNT, AND THE COUNT IS DERIVED BY THE RUN THAT MADE THE CUT.
# Four debate gates in this course have been failed by a panel trimmed without one - most
# recently a thirty-row tree counted as twenty-nine, with the missing row hidden under an
# elision line that claimed to have cut something else. `trim` prints the first N lines of a
# capture and then states, from wc(1), exactly how many it did not print. A bare head is a
# contract breach; this is what replaces it.
trim() {  # $1 = file, $2 = lines to keep, $3 = optional extra sed program for the kept lines
  local f="$1" keep="$2" post="${3:-}"
  [ -s "$f" ] || die "trim: $f is missing or empty, so any elision count over it would be a lie"
  local total; total=$(wc -l < "$f" | tr -d ' ')
  if [ -n "$post" ]; then head -"$keep" "$f" | mask | sed -E "$post"; else head -"$keep" "$f" | mask; fi
  if [ "$total" -gt "$keep" ]; then printf '... %s more line(s) elided\n' "$(( total - keep ))"; fi
  return 0
}
# The same rule for a capture that is SELECTED by pattern rather than cut at a line number:
# say how many lines the whole capture had, so "one line of a stack trace" is never mistaken
# for "the whole of the failure".
of_total() {  # $1 = file, $2 = how many lines were shown
  [ -s "$1" ] || die "of_total: $1 is missing or empty"
  printf '(%s line(s) shown of %s in the whole capture)\n' "$2" "$(wc -l < "$1" | tr -d ' ')"
}
# A DIE BEHIND A PIPE IS NOT A GUARD.
#
# `casebug` and `solution` build their panels inside `{ … } > .r-<id>.out 2>&1` and elide their
# captures as `trim <file> <n> | sed 's/^/  /'`. The left-hand side of a pipeline runs in a
# SUBSHELL: `trim`'s `die` exits THAT shell, the pipeline's status is sed's 0, nobody tests the
# pipeline so `set -o pipefail` never comes into it - and the RECEIPT FAILED line goes to
# stderr, which the `2>&1` puts INSIDE the capture being hashed. Measured here: with the
# captures emptied, `casebug` fired both of its "would be a lie" guards and still printed
# `md5 84e01016f3804058d3acc0b01fb9a8ac  (exit 0, 1, 1)`, `solution` did the same for
# `md5 c43f75d75c6fe339e2779ad8649a26b7  (exit 1 then 0)`, and both times ./receipts.sh
# exited 0 over a capture with RECEIPT FAILED written in it.
#
# So the condition is asserted HERE: current shell, no pipeline, no redirect, where `die` is
# fatal and visible. The pipelines are untouched, so no panel's bytes move.
have_capture() {  # $@ = the captures a panel is about to elide
  local f
  for f in "$@"; do
    [ -s "$f" ] || die "trim: $f is missing or empty, so any elision count over it would be a lie"
  done
}

count_in() {
  [ -s "$1" ] || die "$3: $1 is missing or empty, so any count over it would be a lie"
  grep -cE "$2" "$1" || true
}
count_positive() {
  local n; n=$(count_in "$1" "$2" "$3")
  [ "$n" -gt 0 ] || die "$3: counted 0, and 0 cannot be right here"
  printf '%s' "$n"
}

# --------------------------------------------------------------- workflow ----
# HASHED. The taught material, checked by a YAML parser rather than by eye.
run_workflow() {
  block "workflow - the file, parsed  [HASHED]"
  [ -s "$WF" ] || die "no $WF"
  command -v ruby > /dev/null || die "ruby is needed to parse the workflow; it ships with macOS"

  # Psych (ruby's YAML) either parses it or raises. A workflow that does not parse is not a
  # workflow, and "it looks right" is not a check.
  ruby -ryaml -rjson -e '
    d = YAML.safe_load(File.read(ARGV[0]), aliases: true)
    jobs = d["jobs"]
    out = {
      "name"        => d["name"],
      "jobs"        => jobs.keys,
      # THE KEY `on:` IS NOT THE STRING "on" TO A YAML 1.1 PARSER. It is the BOOLEAN
      # true - the same rule that turns `off`, `yes` and `no` into booleans. GitHub reads
      # its own files with a parser that does not do this; ruby, python and most others do.
      # So look the triggers up under BOTH, and say which one answered.
      "triggers"    => (d["on"] || d[true]).keys,
      "on_key_read_as" => (d.key?("on") ? "the string \"on\"" : (d.key?(true) ? "the BOOLEAN true (YAML 1.1)" : "not found")),
      "top_level_permissions" => d["permissions"],
      "matrix"      => jobs["build"]["strategy"]["matrix"]["java"],
      "fail_fast"   => jobs["build"]["strategy"]["fail-fast"],
      "steps_build" => jobs["build"]["steps"].length,
      "steps_release" => jobs["release"]["steps"].length,
      "release_needs" => jobs["release"]["needs"],
      "release_if"    => jobs["release"]["if"],
      "release_permissions" => jobs["release"]["permissions"],
      "uses"        => (jobs.values.flat_map { |j| j["steps"] }.map { |s| s["uses"] }.compact.uniq.sort),
    }
    puts JSON.pretty_generate(out)
  ' "$WF" > .r-wf.raw 2>&1 || die "the workflow does not parse as YAML; see .r-wf.raw"

  local jobs steps_b uses secrets
  jobs=$(ruby -ryaml -e 'puts YAML.safe_load(File.read(ARGV[0]), aliases: true)["jobs"].keys.length' "$WF")
  steps_b=$(ruby -ryaml -e 'puts YAML.safe_load(File.read(ARGV[0]), aliases: true)["jobs"]["build"]["steps"].length' "$WF")
  uses=$(ruby -ryaml -e 'puts YAML.safe_load(File.read(ARGV[0]), aliases: true)["jobs"].values.flat_map{|j| j["steps"]}.map{|s| s["uses"]}.compact.uniq.length' "$WF")
  [ "$jobs" -ge 2 ] || die "the workflow declares $jobs job(s); the job graph needs at least two"

  # A secret must never be typed, echoed or committed. The only thing allowed in this file
  # is the token GitHub provides, and this counts both halves.
  secrets=$(grep -cE '\$\{\{ *secrets\.' "$WF" || true)
  local nongithub; nongithub=$(grep -oE '\$\{\{ *secrets\.[A-Za-z_]+' "$WF" | grep -vc 'secrets.GITHUB_TOKEN' || true)
  [ "$nongithub" -eq 0 ] || die "the workflow names $nongithub secret(s) other than GITHUB_TOKEN"

  { printf 'the workflow, as a YAML parser sees it:\n'
    sed 's/^/  /' .r-wf.raw
    printf '\njobs ........................................ %s\n' "$jobs"
    printf 'steps in the build job ...................... %s\n' "$steps_b"
    printf 'distinct actions used ....................... %s\n' "$uses"
    printf 'every action pinned to a MAJOR tag (@vN) .... %s of %s\n' \
      "$(ruby -ryaml -e 'puts YAML.safe_load(File.read(ARGV[0]), aliases: true)["jobs"].values.flat_map{|j| j["steps"]}.map{|s| s["uses"]}.compact.uniq.count{|u| u =~ /@v\d+$/}' "$WF")" "$uses"
    printf 'actions pinned to a branch or to @main ...... %s\n' \
      "$(grep -cE 'uses: .*@(main|master)$' "$WF" || true)"
    printf '\nsecret references in the whole file ......... %s\n' "$secrets"
    printf 'of those, anything but secrets.GITHUB_TOKEN . %s\n' "$nongithub"
    printf 'lines containing a literal token or password  %s\n' \
      "$(grep -icE '(ghp_|gho_|password:|token: [A-Za-z0-9]{8})' "$WF" || true)"
  } > .r-workflow.out 2>&1

  cat .r-workflow.out
  printf 'md5 %s  (exit 0)\n' "$(hash_of .r-workflow.out)"
}

# ---------------------------------------------------------------- actions ----
# HASHED, NO NETWORK. Every pin derived from the files in central/.
run_actions() {
  block "actions - what each pin actually resolves to today  [HASHED, no network]"
  local f
  for f in central/actions-checkout-latest.json central/actions-setup-java-latest.json \
           central/actions-cache-latest.json central/actions-upload-artifact-latest.json \
           central/adoptium-available-releases.json; do
    [ -s "$f" ] || die "missing evidence file $f"
  done

  { printf 'action pins in %s, each checked against the release the API reported:\n' "$WF"
    local a n tag pub pinned
    for a in checkout setup-java cache upload-artifact; do
      n="central/actions-$a-latest.json"
      tag=$(python3 -c "import json;print(json.load(open('$n'))['tag_name'])")
      pub=$(python3 -c "import json;print(json.load(open('$n'))['published_at'][:10])")
      pinned=$(grep -oE "actions/$a@v[0-9]+" "$WF" | head -1)
      [ -n "$pinned" ] || { printf '  actions/%-18s NOT USED in this workflow\n' "$a"; continue; }
      printf '  %-28s latest %-8s published %s   pinned as %s\n' "actions/$a" "$tag" "$pub" "${pinned##*/}"
    done
    printf '\na major tag moves and a commit SHA does not:\n'
    printf '  actions/checkout@v7 today resolves to %s\n' "$(python3 -c "import json;print(json.load(open('central/actions-checkout-latest.json'))['tag_name'])")"
    printf '  tomorrow the same line can resolve to something else, and nothing tells you\n'
    printf '\nthe matrix, and why it is 25 plus one:\n'
    printf '  Adoptium LTS releases ............... %s\n' "$(python3 -c "import json;print(json.load(open('central/adoptium-available-releases.json'))['available_lts_releases'])")"
    printf '  most recent LTS ..................... %s\n' "$(python3 -c "import json;print(json.load(open('central/adoptium-available-releases.json'))['most_recent_lts'])")"
    printf '  most recent feature release ......... %s\n' "$(python3 -c "import json;print(json.load(open('central/adoptium-available-releases.json'))['most_recent_feature_release'])")"
    printf '  this workflow matrix ................ %s\n' \
      "$(ruby -ryaml -e 'puts YAML.safe_load(File.read(ARGV[0]), aliases: true)["jobs"]["build"]["strategy"]["matrix"]["java"].join(", ")' "$WF")"
    printf '  so the second leg is a feature release, not a second baseline.\n'
    printf '  Java releases that exist at all, per Adoptium: %s\n' \
      "$(python3 -c "import json;print(json.load(open('central/adoptium-available-releases.json'))['available_releases'])")"
  } > .r-actions.out 2>&1

  cat .r-actions.out
  printf 'md5 %s  (no build, no network)\n' "$(hash_of .r-actions.out)"
}

# ----------------------------------------------------------------- matrix ----
# HASHED. The matrix, run here, on both JDKs, with the same goal the workflow uses.
run_matrix() {
  block "matrix - both legs, run on this machine  [HASHED]"
  [ -x "$JDK25/bin/java" ] || die "no JDK 25 at $JDK25"
  [ -x "$JDK26/bin/java" ] || die "no JDK 26 at $JDK26 - this block cannot fake the second leg"

  local v25 v26 rc25 rc26
  v25=$("$JDK25/bin/java" -version 2>&1 | head -1 | grep -oE '"[^"]+"' | tr -d '"')
  v26=$("$JDK26/bin/java" -version 2>&1 | head -1 | grep -oE '"[^"]+"' | tr -d '"')
  [ "$v25" != "$v26" ] || die "both legs report the same JDK version ($v25) - the matrix is not a matrix"

  JAVA_HOME="$JDK25" PATH="$JDK25/bin:$PATH" mvn -B -ntp -Dmaven.repo.local="$REPO" clean verify > .r-m25.raw 2>&1; rc25=$?
  JAVA_HOME="$JDK26" PATH="$JDK26/bin:$PATH" mvn -B -ntp -Dmaven.repo.local="$REPO" clean verify > .r-m26.raw 2>&1; rc26=$?

  { printf 'the same goal the workflow runs - mvn -B -ntp verify - on both legs:\n'
    printf '  JDK %-10s exit %s   %s\n' "$v25" "$rc25" "$(grep -E '^\[INFO\] Tests run:' .r-m25.raw | tail -1 | sed 's/^\[INFO\] //')"
    printf '  JDK %-10s exit %s   %s\n' "$v26" "$rc26" "$(grep -E '^\[INFO\] Tests run:' .r-m26.raw | tail -1 | sed 's/^\[INFO\] //')"
    printf '\nlegs that went green: %s of 2\n' "$(( (rc25==0) + (rc26==0) ))"
    printf 'release the sources are compiled for, read out of the build: %s\n' \
      "$(grep -oE 'release [0-9]+' .r-m25.raw | head -1)"
    printf 'and the second leg is the compatibility check, not a second baseline.\n'
    printf 'fail-fast in the workflow: %s  (so a red 26 cannot hide a green 25)\n' \
      "$(ruby -ryaml -e 'puts YAML.safe_load(File.read(ARGV[0]), aliases: true)["jobs"]["build"]["strategy"]["fail-fast"]' "$WF")"
  } > .r-matrix.out 2>&1

  cat .r-matrix.out
  printf 'md5 %s  (exit %s, %s)\n' "$(hash_of .r-matrix.out)" "$rc25" "$rc26"
  [ "$rc25" -eq 0 ] || die "the JDK 25 leg is red; that is the baseline and it must be green"
}

# ---------------------------------------------------------------- casebug ----
# HASHED. The one thing a CI unit is actually about: a green build that produced a broken
# artifact. THREE states, two answers, and not one of them needs a runner.
run_casebug() {
  block "casebug - green here, red there, and here is there  [HASHED]"
  "${MVN[@]}" -ntp clean package > .r-pkg.raw 2>&1; local rcp=$?
  [ "$rcp" -eq 0 ] || die "mvn package is not green, so there is no green build to distrust"
  [ -f "$JAR" ] || die "no $JAR"
  local tests; tests=$(grep -E '^\[INFO\] Tests run:' .r-pkg.raw | tail -1 | sed 's/^\[INFO\] //')

  local on_disk; on_disk=$(ls src/main/resources/ | head -1)
  local asked;   asked=$(grep -oE 'RESOURCE = "[^"]+"' src/main/java/com/tiffinbox/ci/MenuLoader.java | grep -oE '"/[^"]+"' | tr -d '"')
  [ "$on_disk" != "${asked#/}" ] || die "the file name and the requested name agree, so there is no bug to teach"

  local rc_a rc_b
  java -cp target/classes com.tiffinbox.ci.MenuLoader > .r-a.raw 2>&1; rc_a=$?
  java -cp "$JAR"          com.tiffinbox.ci.MenuLoader > .r-b.raw 2>&1; rc_b=$?
  [ "$rc_a" -eq 0 ] || die "state (a) failed; on a case-insensitive volume it is supposed to pass"
  [ "$rc_b" -ne 0 ] || die "state (b) passed; a zip entry name is exact and this should not happen"

  # State (c): a case-sensitive volume, made here, in one command, with no privileges.
  local cs_available=no rc_c='' cs_out=''
  hdiutil detach "/Volumes/$CSVOL" -quiet 2>/dev/null || true
  rm -f "$CSIMG"
  if hdiutil create -size 64m -fs 'Case-sensitive APFS' -volname "$CSVOL" -quiet "$CSIMG" 2>/dev/null \
     && hdiutil attach "$CSIMG" -nobrowse -quiet 2>/dev/null; then
    cs_available=yes
    cp -R target/classes "/Volumes/$CSVOL/classes"
    java -cp "/Volumes/$CSVOL/classes" com.tiffinbox.ci.MenuLoader > .r-c.raw 2>&1; rc_c=$?
    # `$(trim …)` is a subshell too: without the `|| exit 1` a dying trim left cs_out EMPTY
    # and this block carried on to print a blank line in state (c)'s panel and hash it.
    cs_out=$(trim .r-c.raw 2) || exit 1
    hdiutil detach "/Volumes/$CSVOL" -quiet 2>/dev/null || true
    rm -f "$CSIMG"
    [ "$rc_c" -ne 0 ] || die "state (c) passed on a case-sensitive volume, which cannot be right"
  fi

  # …and the captures the panel elides, checked before the panel is built rather than inside a
  # pipeline that cannot report it. See have_capture above.
  have_capture .r-a.raw .r-b.raw

  { printf 'the build, first:\n'
    printf '  %s\n' "$tests"
    printf '  mvn package exit code: %s\n' "$rcp"
    printf '\nthe file on disk ........ src/main/resources/%s\n' "$on_disk"
    printf 'the name the code asks for %s\n' "$asked"
    printf 'the two spellings agree: no\n'
    printf '\n(a) the SAME classes, run from target/classes on this Mac:\n'
    trim .r-a.raw 3 | sed 's/^/    /'
    printf '    exit %s\n' "$rc_a"
    printf '\n(b) the SAME classes, run from the jar the same build just produced:\n'
    trim .r-b.raw 2 | sed 's/^/    /'
    printf '    exit %s\n' "$rc_b"
    printf '    (a zip entry name is an exact byte string, on every operating system -\n'
    printf '     packaging is the first place the two spellings stop being the same word)\n'
    if [ "$cs_available" = yes ]; then
      printf '\n(c) the SAME classes, on a case-sensitive volume made here in one command:\n'
      printf '%s\n' "$cs_out" | sed 's/^/    /'
      printf '    exit %s\n' "$rc_c"
      printf '    $ hdiutil create -size 64m -fs "Case-sensitive APFS" -volname <name> <img>\n'
      printf '    no privileges, no network, no runner. That volume is what the runner is.\n'
    else
      printf '\n(c) SKIPPED: hdiutil could not make a case-sensitive volume on this machine.\n'
      printf '    This block does NOT substitute a guess for the measurement.\n'
    fi
    printf '\nstates run: %s ; states that failed: %s\n' \
      "$([ "$cs_available" = yes ] && echo 3 || echo 2)" \
      "$([ "$cs_available" = yes ] && echo 2 || echo 1)"
    printf 'and the build that produced all of them said BUILD SUCCESS: %s\n' \
      "$(grep -c 'BUILD SUCCESS' .r-pkg.raw || true)"
  } > .r-casebug.out 2>&1

  cat .r-casebug.out
  printf 'md5 %s  (exit %s, %s%s)\n' "$(hash_of .r-casebug.out)" "$rc_a" "$rc_b" \
    "$([ -n "$rc_c" ] && printf ', %s' "$rc_c")"
}

# ------------------------------------------------------------------ norun ----
# HASHED - AND THE HASH COVERS THE REPOSITORY, NOT THIS MAC.
#
# The honest block, and it had to be made honest twice. The first version asked this
# machine four questions, wrote all four answers into the file it hashes, and then printed
# one line UNDER the md5 saying the yes/no answers were "not hashed". They were. The same
# repository, on a Mac with no `gh` on the PATH, produced a different md5 - so the figure
# on the slide was a fact about the maintainer's laptop wearing a receipt's clothes.
#
# The split below is the one the lesson actually wants:
#   * `gh installed` and `gh authenticated` are properties of YOUR MACHINE. They are
#     printed BEFORE the capture, outside it, and they cannot move the md5.
#   * `.github/workflows/ present in this repo` and `workflow runs gh can list` are
#     properties of THIS REPOSITORY. They are the lesson - nothing installed, zero runs -
#     they are the same in every clone and every fork of it, and they are inside the hash.
# And a tool that cannot answer is not allowed to be rounded down to a confident zero:
# without `gh`, without a login, or with `gh run list` exiting non-zero, this block die()s
# the way `matrix` die()s without a second JDK, instead of hashing 'n/a'.
run_norun() {
  block "norun - the capture this unit does NOT have  [HASHED]"
  local has_gh=no auth=no runs wf_installed=no
  command -v gh > /dev/null && has_gh=yes
  [ "$has_gh" = yes ] || die "no gh on the PATH, so 'workflow runs gh can list' cannot be measured here - and this block does not hash a number no tool gave it"
  gh auth status > /dev/null 2>&1 && auth=yes
  [ "$auth" = yes ] || die "gh is installed but not logged in, so it cannot be asked what runs this repository has - run 'gh auth login'"

  # stdout only: `gh run list` says "no runs found" on stderr, and counting that as a run
  # would be the same class of mistake as hashing this machine. The exit code is checked
  # because outside a git repository this command FAILS, and a failure piped into wc -l is
  # a zero that no tool ever reported.
  # Both working files are named .r-*.raw because that is the pattern .gitignore already
  # covers for this unit; a .err here would be the one file a receipts run leaves untracked.
  gh run list --limit 100 > .r-runs.raw 2> .r-runs-err.raw; local rc_runs=$?
  [ "$rc_runs" -eq 0 ] || die "gh run list exited $rc_runs, so its answer is an error and not a zero; see .r-runs-err.raw"
  runs=$(grep -c . .r-runs.raw | tr -d ' ')
  [ -d "../.github/workflows" ] && wf_installed=yes
  # The two hashed answers are the two the unit teaches, so they are asserted rather than
  # merely printed: a repository that HAS installed the workflow, or that has runs to list,
  # is a different lesson and must not reuse this block's hash.
  [ "$wf_installed" = no ] || die "../.github/workflows/ exists in this clone, so this repository is no longer the one this block describes"
  [ "$runs" -eq 0 ] || die "gh listed $runs run(s) of this repository; the whole block says there are none"

  printf 'NOT hashed - these two are properties of THIS machine, so they are outside it:\n'
  printf '  gh installed .............................. %s\n' "$has_gh"
  printf '  gh authenticated .......................... %s\n' "$auth"

  { printf 'HASHED - what this repository can say about runs of itself:\n'
    printf '  .github/workflows/ present in this repo .... %s\n' "$wf_installed"
    printf '  workflow runs gh can list ................. %s\n' "$runs"
    printf '\nSo there is no run log, and this unit does not have one.\n'
    printf 'The workflow file in workflows/ has never executed. It is the taught material;\n'
    printf 'it is not evidence of a run, and nothing in this unit dresses it up as one.\n'
    printf '\nWhat would produce one: fork this repository, copy workflows/build.yml to\n'
    printf '.github/workflows/build.yml, push, then\n'
    printf '  $ gh run list --limit 1\n'
    printf '  $ gh run view <id> --log\n'
    printf 'Free minutes are a property of PUBLIC repositories. On a private one the same\n'
    printf 'push spends minutes off a quota, and nobody warns you the first time.\n'
  } > .r-norun.out 2>&1

  cat .r-norun.out
  printf 'md5 %s  (no run to have an exit code)\n' "$(hash_of .r-norun.out)"
}

# --------------------------------------------------------------- solution ----
run_solution() {
  block "solution - the exercise, start state proved first  [HASHED]"
  [ -f exercise/solution/fix.txt ] || die "no answer at exercise/solution/fix.txt"
  [ -f "$JAR" ] || "${MVN[@]}" -ntp -q clean package > .r-pkg.raw 2>&1 || die "build failed"

  local before; java -cp "$JAR" com.tiffinbox.ci.MenuLoader > .r-sb.raw 2>&1; before=$?
  [ "$before" -ne 0 ] || die "the jar already runs - the exercise has nothing to fix"

  # Apply the answer in a COPY: rename the resource to the name the code asks for.
  rm -rf .sol && mkdir -p .sol && cp -R src pom.xml .sol/
  mv .sol/src/main/resources/Menu.json .sol/src/main/resources/menu.json
  ( cd .sol && mvn -B -ntp -q -Dmaven.repo.local="$REPO" clean package ) > .r-sa.raw 2>&1 \
    || die "the answered build failed; see .r-sa.raw"
  local after; java -cp ".sol/$JAR" com.tiffinbox.ci.MenuLoader > .r-sc.raw 2>&1; after=$?

  # …and the two captures the panel elides. See have_capture above.
  have_capture .r-sb.raw .r-sc.raw

  { printf 'start state - the jar the shipped build produces:\n'
    trim .r-sb.raw 2 | sed 's/^/  /'
    printf '  exit %s\n' "$before"
    printf '\nanswer - the resource renamed to the name the code asks for, 0 lines of Java changed:\n'
    trim .r-sc.raw 3 | sed 's/^/  /'
    printf '  exit %s\n' "$after"
    printf '\nJava files that differ between the two trees: %s\n' \
      "$(diff -r --brief src/main/java .sol/src/main/java 2>/dev/null | wc -l | tr -d ' ')"
    printf 'resource files that differ in NAME: %s\n' \
      "$(diff <(ls src/main/resources) <(ls .sol/src/main/resources) | grep -cE '^[<>]' || true)"
    printf 'entries in the answered jar whose name is menu.json: %s\n' \
      "$(unzip -l ".sol/$JAR" | grep -cE ' menu\.json$' || true)"
  } > .r-solution.out 2>&1

  cat .r-solution.out
  printf 'md5 %s  (exit %s then %s)\n' "$(hash_of .r-solution.out)" "$before" "$after"
  [ "$after" -eq 0 ] || die "the answer did not fix the jar"
  rm -rf .sol
}

# ---------------------------------------------------------------- offline ----
run_offline() {
  block "offline - the contract's re-run receipt  [HASHED]"
  "${MVN[@]}" -ntp -q clean package > .r-warm.raw 2>&1 || die "the warm build failed"
  "${MVN[@]}" -ntp -o test > .r-off.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc; see .r-off.raw"
  { grep -E 'Tests run:|BUILD SUCCESS' .r-off.raw | mask
    printf 'offline runs that reached the network: %s\n' "$(grep -c 'Downloading' .r-off.raw || true)"
    printf 'exit code: %s\n' "$rc"
  } > .r-offline.out 2>&1
  cat .r-offline.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-offline.out)" "$rc"
}

case "${1:-all}" in
  workflow) run_workflow ;;
  actions)  run_actions ;;
  matrix)   run_matrix ;;
  casebug)  run_casebug ;;
  norun)    run_norun ;;
  solution) run_solution ;;
  offline)  run_offline ;;
  all) run_workflow; run_actions; run_matrix; run_casebug; run_norun; run_solution; run_offline ;;
  *) echo "unknown block: $1" >&2; exit 2 ;;
esac
