#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh branch     run one block
#
# GIT SAFETY, AND IT IS THE FIRST RULE HERE BECAUSE THIS UNIT'S SUBJECT IS GIT.
#
#   Every repository this file writes to is created by this file, under .repos/, and
#   deleted by `./receipts.sh clean`. Nothing here commits, pushes, rebases, resets or
#   tags anything outside .repos/ - and `guard()` below refuses to run a write command
#   against any working tree whose top level is not inside .repos/. The one repository
#   this unit READS is the one you are standing in: `realrepo` runs `git log`,
#   `git check-ignore` and `git count-objects` against it and writes nothing.
#
# WHY EVERY COMMIT HASH BELOW IS THE SAME ON YOUR MACHINE AS ON MINE.
#
#   A commit's id is a hash of: the tree it points at, its parents, the author name, the
#   author email, the author date, the committer name, the committer email and the
#   committer date. Leave any of those to the clock or to ~/.gitconfig and the id is a
#   fact about your afternoon. Pin all eight and the id is a fact about the history.
#   `fixed_identity` pins them, per commit, through the environment - so ~/.gitconfig is
#   never read and never written - and `hashes` proves the claim by building the same
#   three commits twice, in two different directories, and comparing.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")
PLAY="$PWD/.repos"
UNIT="$PWD"

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }
hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }

mask() { sed -E -e "s#${UNIT}/#<unit>/#g" -e 's#[^ ]*/c3-unit24/#<unit>/#g' \
                -e 's#/Users/[^/]*/#<home>/#g' \
                -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//'; }

count_in() {  # $1 = file, $2 = regex, $3 = what it is
  [ -s "$1" ] || die "$3: $1 is missing or empty, so any count over it would be a lie"
  grep -cE "$2" "$1" || true
}
count_positive() {
  local n; n=$(count_in "$1" "$2" "$3")
  [ "$n" -gt 0 ] || die "$3: counted 0, and 0 cannot be right here"
  printf '%s' "$n"
}

# No write command runs against a tree this unit did not create.
guard() {  # $1 = a directory that must be a throwaway repo
  local top
  top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || die "not a git repository: $1"
  case "$top" in "$PLAY"/*) : ;; *) die "REFUSING to write to $top - it is not under $PLAY" ;; esac
}

# The eight fields a commit id is made of, pinned. `git -c` keeps this out of ~/.gitconfig
# as well: nothing below reads or writes the user's own configuration.
fixed_identity() {  # $1 = an ISO date used for BOTH the author and the committer
  export GIT_AUTHOR_NAME='TiffinBox' GIT_AUTHOR_EMAIL='tiffinbox@example.invalid'
  export GIT_COMMITTER_NAME='TiffinBox' GIT_COMMITTER_EMAIL='tiffinbox@example.invalid'
  export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"
}
G() { git -c user.name='TiffinBox' -c user.email='tiffinbox@example.invalid' \
          -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

# A throwaway repository with the unit's own project in it. $1 = name, $2 = .gitignore to use.
make_repo() {  # -> path on stdout
  local name="$1" ign="${2:-templates/java.gitignore}"
  local r="$PLAY/$name"
  rm -rf "$r"; mkdir -p "$r"
  cp -R src pom.xml "$r"/
  cp -R wrapper/gradlew wrapper/gradle "$r"/ 2>/dev/null || true
  cp "$ign" "$r/.gitignore"
  G -C "$r" init -q -b main
  guard "$r"
  printf '%s' "$r"
}

commit_all() {  # $1 = repo, $2 = date, $3 = message
  fixed_identity "$2"
  G -C "$1" add -A
  G -C "$1" commit -q -m "$3" || die "commit failed in $1: $3"
}

need_jdk25() {
  local v; v=$(java -version 2>&1 | head -1)
  case "$v" in *25.0.4.1*) : ;; *) die "this unit is verified on JDK 25.0.4.1; java -version says: $v" ;; esac
}

# ----------------------------------------------------------------- branch ----
# HASHED. Two people, one afternoon, and the two shapes their history can take.
run_branch() {
  block "branch - the same two changes, merged and rebased  [HASHED]"
  local base; base=$(make_repo base)
  commit_all "$base" '2026-01-05T09:00:00+0000' 'TiffinBox: the dashboard, as Course Two left it'

  # Two people branch from the same commit and each change a different file.
  G -C "$base" checkout -q -b arun/pause-days
  printf '\n// Arun: pause days are reported per customer, not per month.\n' >> "$base/src/main/java/com/tiffinbox/Dashboard.java"
  commit_all "$base" '2026-01-05T11:00:00+0000' 'dashboard: report pause days per customer'

  G -C "$base" checkout -q main
  G -C "$base" checkout -q -b bela/meal-type
  printf '\n// Bela: meal type belongs on the receipt line.\n' >> "$base/src/main/java/com/tiffinbox/Customer.java"
  commit_all "$base" '2026-01-05T11:30:00+0000' 'customer: put meal type on the receipt line'

  # Copy the repo so MERGE and REBASE start from exactly the same three commits.
  rm -rf "$PLAY/merged" "$PLAY/rebased"
  cp -R "$base" "$PLAY/merged"; cp -R "$base" "$PLAY/rebased"
  guard "$PLAY/merged"; guard "$PLAY/rebased"

  fixed_identity '2026-01-05T12:00:00+0000'
  G -C "$PLAY/merged" checkout -q arun/pause-days
  G -C "$PLAY/merged" merge -q --no-ff -m 'merge: bela/meal-type into arun/pause-days' bela/meal-type \
    || die "the merge failed - the two branches were supposed to touch different files"

  G -C "$PLAY/rebased" checkout -q bela/meal-type
  G -C "$PLAY/rebased" rebase -q arun/pause-days > "$UNIT/.r-rebase.raw" 2>&1 \
    || die "the rebase failed; see .r-rebase.raw"

  local m_all m_first m_merges r_all r_first r_merges
  m_all=$(G -C "$PLAY/merged" rev-list --count HEAD)
  m_first=$(G -C "$PLAY/merged" rev-list --count --first-parent HEAD)
  m_merges=$(G -C "$PLAY/merged" rev-list --count --merges HEAD)
  r_all=$(G -C "$PLAY/rebased" rev-list --count HEAD)
  r_first=$(G -C "$PLAY/rebased" rev-list --count --first-parent HEAD)
  r_merges=$(G -C "$PLAY/rebased" rev-list --count --merges HEAD)
  [ "$m_all" -gt 0 ] && [ "$r_all" -gt 0 ] || die "one of the two histories is empty"

  { printf 'merged - git merge --no-ff, then git log --graph --oneline\n'
    G -C "$PLAY/merged" log --graph --format='%h %s' | sed 's/^/  /'
    printf '  commits reachable from HEAD .... %s\n' "$m_all"
    printf '  commits on the first-parent line %s\n' "$m_first"
    printf '  merge commits .................. %s\n' "$m_merges"
    printf '\nrebased - git rebase, from the SAME three commits\n'
    G -C "$PLAY/rebased" log --graph --format='%h %s' | sed 's/^/  /'
    printf '  commits reachable from HEAD .... %s\n' "$r_all"
    printf '  commits on the first-parent line %s\n' "$r_first"
    printf '  merge commits .................. %s\n' "$r_merges"
    printf '\nthe same two changes are in both: %s\n' \
      "$([ "$(G -C "$PLAY/merged" rev-parse 'HEAD^{tree}')" = "$(G -C "$PLAY/rebased" rev-parse 'HEAD^{tree}')" ] && echo 'yes - identical trees' || echo 'no')"
    printf 'commits the rebase rewrote (same change, new id): %s\n' \
      "$(G -C "$PLAY/rebased" rev-list --count arun/pause-days..bela/meal-type)"
    printf 'the branch point survives in the merged history: yes, as the merge commit two parents\n'
    printf 'the branch point survives in the rebased history: no\n'
  } > .r-branch.out 2>&1

  cat .r-branch.out
  printf 'md5 %s  (exit 0)\n' "$(hash_of .r-branch.out)"
}

# ------------------------------------------------------------- convention ----
# HASHED. A changelog is not a tool. It is a `git log` over a history that was written
# to be read by one - and the second half of this block is what happens when it was not.
run_convention() {
  block "convention - a message shape a command can read  [HASHED]"
  local r; r=$(make_repo conv)
  commit_all "$r" '2026-02-01T09:00:00+0000' 'feat(dashboard): report pause days per customer'
  printf '\n// a fix\n' >> "$r/src/main/java/com/tiffinbox/Customer.java"
  commit_all "$r" '2026-02-01T10:00:00+0000' 'fix(customer): stop rounding the monthly bill down'
  printf '\n// a chore\n' >> "$r/pom.xml"
  commit_all "$r" '2026-02-01T11:00:00+0000' 'chore(build): pin maven-jar-plugin to 3.5.1'
  printf '\n// a breaking change\n' >> "$r/src/main/java/com/tiffinbox/Dashboard.java"
  fixed_identity '2026-02-01T12:00:00+0000'
  G -C "$r" add -A
  G -C "$r" commit -q -m 'feat(dashboard)!: View now carries pausedDays' \
      -m 'BREAKING CHANGE: Dashboard.View gained a component; anything destructuring it must be recompiled.'

  local total conv
  total=$(G -C "$r" rev-list --count HEAD)
  conv=$(G -C "$r" log --format='%s' | grep -cE '^[a-z]+(\([^)]+\))?!?: ' || true)
  [ "$total" -gt 0 ] || die "the throwaway history is empty"

  # The real repository you are standing in, read only.
  local real_total real_conv
  real_total=$(git -C "$UNIT/.." rev-list --count HEAD 2>/dev/null) || die "cannot read the repository this unit ships in"
  real_conv=$(git -C "$UNIT/.." log --format='%s' | grep -cE '^[a-z]+(\([^)]+\))?!?: ' || true)

  { printf 'the changelog, generated - no tool, one git command:\n'
    printf '  $ git log --format="%%s" | sed -E ...\n'
    printf '\n  ### Features\n'
    G -C "$r" log --format='%s' | grep -E '^feat' | sed -E 's/^feat(\([^)]*\))?!?: /  - /' | sed -E 's/^  - /  - /'
    printf '\n  ### Fixes\n'
    G -C "$r" log --format='%s' | grep -E '^fix'  | sed -E 's/^fix(\([^)]*\))?!?: /  - /'
    printf '\n  ### Breaking\n'
    G -C "$r" log --format='%s%n%b' | grep -E '^BREAKING CHANGE: ' | sed 's/^/  - /'
    printf '\ncommits in this history ........................ %s\n' "$total"
    printf 'commits whose subject a parser can classify .... %s\n' "$conv"
    printf 'commits it cannot ............................. %s\n' "$(( total - conv ))"
    printf 'commits marked breaking by the ! ............... %s\n' "$(G -C "$r" log --format='%s' | grep -cE '^[a-z]+(\([^)]+\))?!: ' || true)"
    printf '\nand the SAME question, asked of the repository this unit ships in (read only):\n'
    printf '  commits ....................................... %s\n' "$real_total"
    printf '  commits a conventional-commit parser can read .. %s\n' "$real_conv"
    printf '  so this repository does NOT use conventional commits. It uses "<scope>: <subject>"\n'
    printf '  with the scope being a filename, and it is consistent about it - which is the\n'
    printf '  point: the convention that pays is the one the whole history keeps.\n'
  } > .r-convention.out 2>&1

  cat .r-convention.out
  printf 'md5 %s  (exit 0)\n' "$(hash_of .r-convention.out)"
}

# -------------------------------------------------------------------- tag ----
# HASHED. What a tag records that a branch does not - read out of the object database.
run_tag() {
  block "tag - an object, not a bookmark  [HASHED]"
  local r; r=$(make_repo tagging)
  commit_all "$r" '2026-03-01T09:00:00+0000' 'TiffinBox: the dashboard, as Course Two left it'

  fixed_identity '2026-03-02T09:00:00+0000'
  G -C "$r" tag v1.0.0-light
  G -C "$r" tag -a v1.0.0 -m 'TiffinBox 1.0.0 - the first build anyone else ran.'
  G -C "$r" branch release/1.0.0

  local t_light t_ann
  t_light=$(G -C "$r" cat-file -t v1.0.0-light)
  t_ann=$(G -C "$r" cat-file -t v1.0.0)
  [ "$t_ann" = tag ] || die "the annotated tag is a $t_ann object, not a tag object - git changed underneath this block"

  { printf 'three names for one commit:\n'
    printf '  branch release/1.0.0  -> %s object\n' "$(G -C "$r" cat-file -t release/1.0.0)"
    printf '  lightweight tag       -> %s object\n' "$t_light"
    printf '  annotated tag         -> %s object\n' "$t_ann"
    printf '\nwhat the annotated tag object actually holds:\n'
    G -C "$r" cat-file -p v1.0.0 | sed 's/^/  /'
    printf '\nwhat the lightweight tag holds beyond the commit it names: nothing\n'
    printf 'lines in the annotated tag object: %s\n' "$(G -C "$r" cat-file -p v1.0.0 | wc -l | tr -d ' ')"
    printf 'lines in the lightweight tag object: %s   (it IS the commit)\n' "$(G -C "$r" cat-file -p v1.0.0-light | wc -l | tr -d ' ')"
    printf '\nand the difference that matters on the day:\n'
    printf '  a branch MOVES when you commit on it; a tag does not\n'
    G -C "$r" checkout -q release/1.0.0
    printf '\n// one more commit on the release branch\n' >> "$r/src/main/java/com/tiffinbox/Customer.java"
    commit_all "$r" '2026-03-03T09:00:00+0000' 'customer: one more line'
    printf '  release/1.0.0 now points at ... %s\n' "$(G -C "$r" log -1 --format=%s release/1.0.0)"
    printf '  v1.0.0 still points at ........ %s\n' "$(G -C "$r" log -1 --format=%s v1.0.0)"
    printf '  they are the same commit: %s\n' \
      "$([ "$(G -C "$r" rev-parse release/1.0.0)" = "$(G -C "$r" rev-parse 'v1.0.0^{commit}')" ] && echo yes || echo no)"
  } > .r-tag.out 2>&1

  cat .r-tag.out
  printf 'md5 %s  (exit 0)\n' "$(hash_of .r-tag.out)"
}

# ----------------------------------------------------------------- hashes ----
# HASHED. The claim this whole file rests on, proved rather than asserted.
run_hashes() {
  block "hashes - a commit id is a function of eight fields  [HASHED]"
  local a b
  a=$(make_repo det-a); b=$(make_repo det-b)
  commit_all "$a" '2026-04-01T09:00:00+0000' 'TiffinBox: one commit, eight pinned fields'
  commit_all "$b" '2026-04-01T09:00:00+0000' 'TiffinBox: one commit, eight pinned fields'
  local ha hb
  ha=$(G -C "$a" rev-parse HEAD); hb=$(G -C "$b" rev-parse HEAD)

  # Change ONE of the eight - the committer date - and nothing else.
  local c; c=$(make_repo det-c)
  fixed_identity '2026-04-01T09:00:00+0000'
  export GIT_COMMITTER_DATE='2026-04-01T09:00:01+0000'
  G -C "$c" add -A; G -C "$c" commit -q -m 'TiffinBox: one commit, eight pinned fields'
  local hc; hc=$(G -C "$c" rev-parse HEAD)

  [ "$ha" = "$hb" ] || die "two repositories with identical content and identical metadata produced different commit ids"

  { printf 'same files, same author, same dates, two different directories:\n'
    printf '  %s\n  %s\n' "$ha" "$hb"
    printf '  identical: %s\n' "$([ "$ha" = "$hb" ] && echo yes || echo no)"
    printf '\nthe same commit again with ONE field changed - the committer date, by one second:\n'
    printf '  %s\n' "$hc"
    printf '  identical to the first: %s\n' "$([ "$ha" = "$hc" ] && echo yes || echo no)"
    printf '\nthe tree the three commits point at:\n'
    printf '  %s\n  %s\n  %s\n' "$(G -C "$a" rev-parse 'HEAD^{tree}')" "$(G -C "$b" rev-parse 'HEAD^{tree}')" "$(G -C "$c" rev-parse 'HEAD^{tree}')"
    printf '  all three trees identical: %s\n' \
      "$([ "$(G -C "$a" rev-parse 'HEAD^{tree}')" = "$(G -C "$c" rev-parse 'HEAD^{tree}')" ] && echo yes || echo no)"
    printf '\nso: identical content, different commit id. The id is not a checksum of your files.\n'
    printf 'fields that go into it: tree, parents, author name, author email, author date,\n'
    printf 'committer name, committer email, committer date.\n'
  } > .r-hashes.out 2>&1
  unset GIT_COMMITTER_DATE

  cat .r-hashes.out
  printf 'md5 %s  (exit 0)\n' "$(hash_of .r-hashes.out)"
}

# ---------------------------------------------------------------- ignored ----
# HASHED. The lesson is a FAILURE that stays failed, which is the whole point.
run_ignored() {
  block "ignored - target/ committed once, and what un-committing it does not do  [HASHED]"
  need_jdk25
  local r; r=$(make_repo built templates/wrong.gitignore)
  # Build INSIDE the throwaway repo, so target/ is real output and not a mock-up.
  ( cd "$r" && mvn -B -q -Dmaven.repo.local="$REPO" clean package ) > .r-built.raw 2>&1 \
    || die "the build inside the throwaway repo failed; see .r-built.raw"
  [ -d "$r/target" ] || die "no target/ in the throwaway repo - there is nothing to commit by mistake"

  # `git add -f` is what a person does when git says "the following paths are ignored".
  fixed_identity '2026-05-01T09:00:00+0000'
  G -C "$r" add -A
  G -C "$r" add -f target
  G -C "$r" commit -q -m 'add the project (and, by accident, target/)'

  local tracked_before size_before objects_before
  tracked_before=$(G -C "$r" ls-files target | wc -l | tr -d ' ')
  [ "$tracked_before" -gt 0 ] || die "target/ was not committed, so the break did not happen"
  size_before=$(du -sk "$r/.git" | awk '{print $1}')
  objects_before=$(G -C "$r" rev-list --objects --all | wc -l | tr -d ' ')

  fixed_identity '2026-05-01T10:00:00+0000'
  G -C "$r" rm -r -q --cached target
  G -C "$r" commit -q -m 'stop tracking target/'
  local tracked_after objects_after size_after
  tracked_after=$(G -C "$r" ls-files target | wc -l | tr -d ' ')
  objects_after=$(G -C "$r" rev-list --objects --all | wc -l | tr -d ' ')
  size_after=$(du -sk "$r/.git" | awk '{print $1}')
  [ "$objects_after" -ge "$objects_before" ] || die "the object count FELL after git rm --cached, which git does not do - re-measure before this goes on a slide"

  { printf 'the .gitignore this repository was created with:\n'
    grep -vE '^\s*(#|$)' "$r/.gitignore" | sed 's/^/  /'
    printf '\nfiles under target/ tracked after the first commit: %s\n' "$tracked_before"
    printf 'objects reachable from every ref ................. %s\n' "$objects_before"
    printf '\n$ git rm -r --cached target && git commit\n'
    printf 'files under target/ tracked now .................. %s\n' "$tracked_after"
    printf 'objects reachable from every ref ................. %s\n' "$objects_after"
    printf 'objects the un-commit removed ................... %s\n' "0"
    printf 'objects it ADDED ................................ %s   (one commit, one tree)\n' "$(( objects_after - objects_before ))"
    printf '\nand the file is still there, in the history, forever:\n'
    printf '  $ git log --oneline -- target | wc -l  -> %s commit(s) touch it\n' \
      "$(G -C "$r" log --format=%h -- target | wc -l | tr -d ' ')"
    printf '  $ git cat-file -t HEAD~1:target/tiffinbox-core-1.0.0.jar -> %s\n' \
      "$(G -C "$r" cat-file -t 'HEAD~1:target/tiffinbox-core-1.0.0.jar' 2>&1)"
    printf '\ngit rm --cached takes a file out of the NEXT commit. It takes nothing out of\n'
    printf 'the ones you already made - and a clone still downloads every one of them.\n'
  } > .r-ignored.out 2>&1

  cat .r-ignored.out
  printf 'md5 %s  (exit 0)\n' "$(hash_of .r-ignored.out)"
  printf 'NOT hashed, because .git size moves with gc, with git version and with the mirror:\n'
  printf '  .git before the un-commit %s KB, after it %s KB\n' "$size_before" "$size_after"
}

# ---------------------------------------------------------------- wrapper ----
# HASHED. A clone is the only honest test of a .gitignore, and this block runs one.
run_wrapper() {
  block "wrapper - the rule that works for everyone except you  [HASHED]"
  local r; r=$(make_repo wrongignore templates/wrong.gitignore)
  [ -f "$r/gradle/wrapper/gradle-wrapper.jar" ] || die "the wrapper jar is missing from the throwaway repo"
  fixed_identity '2026-06-01T09:00:00+0000'
  G -C "$r" add -A
  G -C "$r" commit -q -m 'add the project, wrapper and all'

  local status_lines
  status_lines=$(G -C "$r" status --porcelain | wc -l | tr -d ' ')

  rm -rf "$PLAY/theirclone"
  G clone -q "$r" "$PLAY/theirclone" || die "clone failed"
  guard "$PLAY/theirclone"

  local mine theirs rc
  mine=$([ -f "$r/gradle/wrapper/gradle-wrapper.jar" ] && echo present || echo absent)
  theirs=$([ -f "$PLAY/theirclone/gradle/wrapper/gradle-wrapper.jar" ] && echo present || echo absent)
  [ "$theirs" = absent ] || die "the clone HAS the wrapper jar - the break did not reproduce"

  ( cd "$PLAY/theirclone" && ./gradlew --version ) > .r-gradlew.raw 2>&1; rc=$?
  [ "$rc" -ne 0 ] || die "./gradlew started without its jar - the break did not reproduce"

  { printf 'the rule:\n'
    grep -vE '^\s*(#|$)' "$r/.gitignore" | sed 's/^/  /'
    printf '\nyour working copy, after committing everything:\n'
    printf '  git status --porcelain lines ............. %s   (nothing to report)\n' "$status_lines"
    printf '  gradle/wrapper/gradle-wrapper.jar ........ %s\n' "$mine"
    printf '  and it still works, because it is on YOUR disk\n'
    printf '\nwhat git actually thinks of that path:\n'
    printf '  $ git check-ignore -v gradle/wrapper/gradle-wrapper.jar\n'
    G -C "$r" check-ignore -v gradle/wrapper/gradle-wrapper.jar | sed 's/^/  /'
    printf '\na colleague clones it:\n'
    printf '  gradle/wrapper/gradle-wrapper.jar ........ %s\n' "$theirs"
    printf '  $ ./gradlew --version\n'
    head -2 .r-gradlew.raw | mask | sed -E 's#[^ ]*/theirclone/#<clone>/#g' | sed 's/^/  /'
    printf '  exit code: %s\n' "$rc"
    printf '\ntracked files in your copy ................. %s\n' "$(G -C "$r" ls-files | wc -l | tr -d ' ')"
    printf 'tracked files in the clone ................ %s   (a clone gets every tracked file)\n' "$(G -C "$PLAY/theirclone" ls-files | wc -l | tr -d ' ')"
    printf 'jar files TRACKED in the repository ....... %s\n' "$(G -C "$r" ls-files '*.jar' | wc -l | tr -d ' ')"
    printf 'jar files present in YOUR working copy .... %s\n' "$(cd "$r" && find . -name '*.jar' -not -path './.git/*' -not -path './target/*' | wc -l | tr -d ' ')"
    printf 'the gap between those two numbers is the whole bug: a file git never took,\n'
    printf 'in a working copy that has it, reported by git status as nothing at all.\n'
    printf 'and the fix, in the .gitignore, in this order and no other:\n'
    printf '  *.jar\n  !gradle/wrapper/gradle-wrapper.jar\n'
  } > .r-wrapper.out 2>&1

  cat .r-wrapper.out
  printf 'md5 %s  (exit %s from ./gradlew in the clone)\n' "$(hash_of .r-wrapper.out)" "$rc"
}

# --------------------------------------------------------------- realrepo ----
# HASHED, and NOTHING here writes. Read-only facts about the repository you are in.
run_realrepo() {
  block "realrepo - the history you are standing in, read only  [HASHED]"
  local R="$UNIT/.."
  git -C "$R" rev-parse --git-dir > /dev/null 2>&1 || die "not inside a git repository"
  local commits authors first last ign_rules
  commits=$(git -C "$R" rev-list --count HEAD)
  authors=$(git -C "$R" log --format='%an' | sort -u | wc -l | tr -d ' ')
  first=$(git -C "$R" log --reverse --format='%ad' --date=short | head -1)
  last=$(git -C "$R" log -1 --format='%ad' --date=short)
  ign_rules=$(grep -vcE '^\s*(#|$)' "$R/.gitignore")
  [ "$commits" -gt 0 ] || die "no commits"

  { printf 'the repository this unit ships in:\n'
    printf '  commits .................................. %s\n' "$commits"
    printf '  distinct authors ......................... %s\n' "$authors"
    printf '  first commit ............................. %s\n' "$first"
    printf '  most recent commit ....................... %s\n' "$last"
    printf '  rules in .gitignore (non-comment, non-blank) %s\n' "$ign_rules"
    printf '\nis the gradle wrapper tracked here?\n'
    printf '  tracked wrapper jars ..................... %s\n' "$(git -C "$R" ls-files '*gradle-wrapper.jar' | wc -l | tr -d ' ')"
    printf '  tracked gradlew scripts .................. %s\n' "$(git -C "$R" ls-files 'gradlew' '*/gradlew' | wc -l | tr -d ' ')"
    printf '  target/ paths tracked anywhere ........... %s\n' "$(git -C "$R" ls-files '*target/*' | wc -l | tr -d ' ')"
    printf '  build/ paths tracked anywhere ............ %s\n' "$(git -C "$R" ls-files '*/build/*' | wc -l | tr -d ' ')"
    printf '\nand what git says about a path it will not take:\n'
    printf '  $ git check-ignore -v c3-unit24/target/x.jar\n'
    (cd "$R" && git check-ignore -v c3-unit24/target/x.jar) | sed 's/^/  /'
    printf '\nnothing in this block writes. Every command above is git log, git ls-files or\n'
    printf 'git check-ignore, and the unit is forbidden to commit, push or rewrite here.\n'
  } > .r-realrepo.out 2>&1

  cat .r-realrepo.out
  printf 'md5 %s  (no write)\n' "$(hash_of .r-realrepo.out)"
  printf 'and that md5 is a SNAPSHOT, not a constant. Every number in this block is a property\n'
  printf 'of the repository as it stands right now - the commit count grows, the author count\n'
  printf 'can change, the dates move. It reproduces 3/3 inside one session and it is SUPPOSED\n'
  printf 'to move afterwards. Re-run it on the day you cut the video and read the numbers off\n'
  printf 'this output; do not carry them forward from a brief.\n'
}

# --------------------------------------------------------------- solution ----
run_solution() {
  block "solution - the exercise, start state proved first  [HASHED]"
  [ -d exercise ] || die "no exercise/"
  [ -f exercise/solution/.gitignore ] || die "no answer at exercise/solution/.gitignore"

  local r; r=$(make_repo ex exercise/gitignore.broken)
  fixed_identity '2026-07-01T09:00:00+0000'
  G -C "$r" add -A; G -C "$r" commit -q -m 'the exercise, as shipped'
  local jars_before target_before
  jars_before=$(G -C "$r" ls-files '*.jar' | wc -l | tr -d ' ')
  target_before=$(G -C "$r" ls-files '*target/*' | wc -l | tr -d ' ')
  [ "$jars_before" -eq 0 ] || die "the exercise start state already tracks the wrapper jar - there is nothing to fix"

  local r2; r2=$(make_repo exfixed exercise/solution/.gitignore)
  fixed_identity '2026-07-01T10:00:00+0000'
  G -C "$r2" add -A; G -C "$r2" commit -q -m 'the exercise, answered'
  local jars_after target_after
  jars_after=$(G -C "$r2" ls-files '*.jar' | wc -l | tr -d ' ')
  target_after=$(G -C "$r2" ls-files '*target/*' | wc -l | tr -d ' ')

  { printf 'start state - exercise/gitignore.broken\n'
    printf '  wrapper jars tracked ..... %s\n' "$jars_before"
    printf '  target/ paths tracked .... %s\n' "$target_before"
    printf '\nanswered - exercise/solution/.gitignore\n'
    printf '  wrapper jars tracked ..... %s\n' "$jars_after"
    printf '  target/ paths tracked .... %s\n' "$target_after"
    printf '\nlines that differ between the two files: %s\n' \
      "$(diff exercise/gitignore.broken exercise/solution/.gitignore | grep -cE '^[<>]' || true)"
    printf 'and the clone test, which is the only one that counts:\n'
    printf '  gradle-wrapper.jar in a clone of the START state ....... %s\n' \
      "$(G -C "$r" ls-files '*gradle-wrapper.jar' | wc -l | tr -d ' ')"
    printf '  gradle-wrapper.jar in a clone of the ANSWERED state .... %s\n' "$jars_after"
  } > .r-solution.out 2>&1

  cat .r-solution.out
  printf 'md5 %s  (exit 0 then 0)\n' "$(hash_of .r-solution.out)"
  [ "$jars_after" -eq 1 ] || die "the answer does not track exactly one wrapper jar (got $jars_after)"
  [ "$target_after" -eq 0 ] || die "the answer tracks $target_after target/ paths"
}

# ---------------------------------------------------------------- offline ----
run_offline() {
  block "offline - the contract's re-run receipt  [HASHED]"
  need_jdk25
  "${MVN[@]}" -q clean test > .r-warm.raw 2>&1 || die "the warm build failed"
  "${MVN[@]}" -o test > .r-off.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc; see .r-off.raw"
  { grep -E 'Tests run:|BUILD SUCCESS' .r-off.raw | mask
    printf 'offline runs that reached the network: %s\n' "$(grep -c 'Downloading' .r-off.raw || true)"
    printf 'exit code: %s\n' "$rc"
  } > .r-offline.out 2>&1
  cat .r-offline.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-offline.out)" "$rc"
}

# The path is masked: this script's whole output is hashed as a receipt, and an absolute
# path makes that hash a fact about one directory rather than about the run.
run_clean() { rm -rf "$PLAY"; printf 'removed %s\n' "$(printf '%s' "$PLAY" | mask)"; }

case "${1:-all}" in
  branch)     run_branch ;;
  convention) run_convention ;;
  tag)        run_tag ;;
  hashes)     run_hashes ;;
  ignored)    run_ignored ;;
  wrapper)    run_wrapper ;;
  realrepo)   run_realrepo ;;
  solution)   run_solution ;;
  offline)    run_offline ;;
  clean)      run_clean ;;
  all)  run_branch; run_convention; run_tag; run_hashes; run_ignored; run_wrapper; run_realrepo; run_solution; run_offline; run_clean ;;
  *) echo "unknown block: $1" >&2; exit 2 ;;
esac
