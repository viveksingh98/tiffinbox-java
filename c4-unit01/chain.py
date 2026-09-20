import sys, re
# The Caused-by chain filter. It keeps every "Exception in thread" and every "Caused by:" line
# plus the FIRST frame under each, and reports the frames it removed with a DERIVED count.
#
# It also removes ONE thing besides frames: the container's own java.util.logging record of a
# cancelled refresh, which is two lines - a timestamped header and the level line under it -
# and is a duplicate of the exception this file already contains. That record carries the only
# token in a failure capture that cannot be reproduced, so it goes before hashing.
#
# TWO RULES ABOUT THAT REMOVAL, both learned the hard way:
#
# 1. IT IS MATCHED ON STRUCTURE, NEVER ON AN ENGLISH WORD. The old filter matched the month
#    name (Jan|Feb|...) and the literal "WARNING:". Both are localised from the JVM's default
#    locale: under -Duser.language=de the same run prints "Sept. ... WARNUNG:" and under fr
#    "sept. ... AVERTISSEMENT:", the timestamp survives the filter, and the md5 moves - while
#    the derived frame counts stay identical, so nothing flags it. What is NOT localised is
#    Spring's own message text, so that is what this matches.
# 2. NO OTHER "WARNING:" LINE IS TOUCHED. The old filter deleted every line starting with
#    WARNING:, uncounted - including the JDK's sun.misc.Unsafe and CGLIB integrity warnings,
#    which this track's standing rule says are SHOWN, not cropped.
#
# And it FAILS rather than hand back a quietly wrong receipt: if the input contains a cancelled
# refresh and this filter removed none of it, exit 2.

REFRESH = "Exception encountered during context initialization"
LEVEL = re.compile(r'^\S[^\n]*?:\s')          # "<LEVEL>: ..." in any language

raw = [l.rstrip("\n") for l in open(sys.argv[1])]

# Find the cancelled-refresh record: the level line carrying Spring's own message, and the
# JUL header line immediately above it. Matched by the message, never by the month or level.
drop = set()
for i, l in enumerate(raw):
    if REFRESH in l and LEVEL.match(l) and not l.startswith("Exception in thread"):
        drop.add(i)
        if i and not raw[i - 1].startswith(("\tat ", "\t... ", "Caused by:", "Exception in thread")):
            drop.add(i - 1)
if any(REFRESH in l for l in raw) and not drop:
    sys.stderr.write("chain: the input records a cancelled refresh and this filter removed "
                     "none of it - the shape it matches has changed.\n")
    sys.exit(2)

lines = [l for i, l in enumerate(raw) if i not in drop]

out, pending = [], []
def flush():
    global pending
    if not pending: return
    out.append(pending[0])                       # first frame under the header
    rest = pending[1:]
    if rest: out.append("\t... %d frames elided ..." % len(rest))
    pending = []
if drop:
    out.append("... %d log lines elided: the container's own timestamped record of the "
               "cancelled refresh, which this capture already carries as the exception ..."
               % len(drop))
for l in lines:
    if l.startswith("Exception in thread") or l.startswith("Caused by:"):
        flush(); out.append(l)
    elif l.startswith("\tat ") or l.startswith("\t... "):
        pending.append(l)
    else:
        flush(); out.append(l)
flush()
print("\n".join(out))
