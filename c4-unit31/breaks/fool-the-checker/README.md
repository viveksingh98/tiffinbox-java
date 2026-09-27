# fool-the-checker — a break for the CHECKER, not for the app

Two edits laid over the rewired anchor, taken from the RED review of this section (S6 #4):

- `Database.java` — one of the three identical `ps.addBatch();` lines deleted;
- `OrderQueue.java` — `cooked.incrementAndGet();` written twice.

Served, the application now returns different numbers. The first version of `onlyannotations.py` only asked
whether each changed line existed *somewhere* in the other file, so it reported `0` for this tree and exited
`0`. The current version compares the code line by line, in order. `receipts.sh` requires it to report
**2 differing lines and exit 1** here. If it ever passes this tree, the checker is broken again and the
receipts stop.

These files carry no comment on purpose: a comment line is code to the checker, and would change the count.
