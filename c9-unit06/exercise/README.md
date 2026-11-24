# Unit 06 exercise — read Priya back from the public address

**Your turn:** this read asks for Priya on the public address and gets four oh four. Fix one word so it answers two hundred.

Start TiffinBox from this unit's `after/` (H2 in memory, its own jar, nothing else) on a port of your own, then run the read and its check
from this folder:

```bash
PORT=20958 sh check.sh
```

What it prints (`read.sh` as shipped):

```
FAIL: status 404 · /api/v1/customers/priya · the body's name none
```

`check.sh` removes the saved answer first, runs `read.sh`, and passes only on a two-hundred from the public address for Priya
(`/api/v1/customers/Priya`) whose body is Priya's record. The fix is one word of `read.sh`'s `curl` line: `SOLUTION.md`.
