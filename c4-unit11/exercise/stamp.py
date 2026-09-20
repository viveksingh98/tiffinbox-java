import sys, re
# The timestamp mask, for a capture whose log line IS the lesson.
#
# chain.py drops the container's record of a CANCELLED refresh, because that record is a
# duplicate of an exception the capture already carries. This unit's break does not cancel
# anything: the container logs a warning and carries on, and that warning is the whole point.
# The track's standing rule is that such lines are SHOWN, not cropped - so the line stays and
# only the token that cannot reproduce is masked.
#
# MATCHED ON STRUCTURE, NEVER ON AN ENGLISH WORD. A java.util.logging record is two lines: a
# header ending in "<fully.qualified.ClassName> <methodName>", and a "<LEVEL>: ..." line under
# it. Both the month name and the level word are localised from the JVM's default locale, so
# neither is matched. What is matched is: a line whose NEXT line is a level line, and which
# contains a fully-qualified class name. Everything before that class name is the timestamp.
#
# AND IT COUNTS WHAT IT MASKED, into the capture, and exits 2 if it masked nothing while a
# level line was present - an uncounted filter that silently does nothing is how a capture
# stops being evidence.

LEVEL = re.compile(r'^\S[^\n]*?:\s')
FQCN = re.compile(r'(?<![\w.$])((?:[a-z][a-zA-Z0-9_]*\.)+[A-Z][A-Za-z0-9_$]*)')

lines = [l.rstrip("\n") for l in open(sys.argv[1])]
out, masked = [], 0
for i, l in enumerate(lines):
    nxt = lines[i + 1] if i + 1 < len(lines) else ""
    m = FQCN.search(l)
    if m and LEVEL.match(nxt) and not l.startswith(("\tat ", "\t... ", "Caused by:")) \
            and m.start() > 0:
        out.append("<timestamp> " + l[m.start():])
        masked += 1
    else:
        out.append(l)

if any(LEVEL.match(l) and not l.startswith("Exception in thread") for l in lines) and not masked:
    sys.stderr.write("stamp: the input carries a log record and this filter masked none of "
                     "it - the shape it matches has changed.\n")
    sys.exit(2)

print("... %d log timestamps masked to <timestamp>: the only token in these records that "
      "cannot reproduce. The records themselves are shown, not cropped ..." % masked)
print("\n".join(out))
