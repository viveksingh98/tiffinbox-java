# Solution

Measured 2026-09-30 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1), after `../receipts.sh` had built `after/`, by running
`../README.md`'s two blocks **exactly as written**, then the block below, from the unit's folder, in one clean shell
(`env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin bash --noprofile --norc`: nothing but the
block's own two `export` lines chose the JDK, `/opt/homebrew/bin` is where Maven lives on this Mac, and no variable of the
author's could become a property source). The token was `openssl rand -hex 16`'s, and no command printed it. Port 18719
had no listener at the end.

## The move

`application.yaml` imports `optional:configtree:./secrets/`: a config tree, one file per key, in the folder TiffinBox
starts in. For the key `tiffinbox.shutdown-token`, the file is `secrets/tiffinbox/shutdown-token` (the unit's `ranks`
capture shows that source answering, and its `where` capture shows the file's shape). `printf '%s\n'` writes the token
and a newline — `printf` is the shell's own, so the token is never on a command line — and `umask 077` makes the file
readable by you alone. Then TiffinBox starts with no `TIFFINBOX_` variable:

```bash
mkdir -p secrets/tiffinbox && (umask 077 && printf '%s\n' "$TOKEN" > secrets/tiffinbox/shutdown-token)
stat -f '%Sp %z bytes %N' secrets/tiffinbox/shutdown-token
java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18719 > tiffinbox.log 2>&1 &
for i in $(seq 1 60); do curl -s -o /dev/null http://127.0.0.1:18719/kitchen && break; sleep 0.5; done
ps eww -o command= -p $! | tr ' ' '\n' | grep -c '^TIFFINBOX_'
../../curlset.sh 18719 secrets/tiffinbox/shutdown-token | tail -1; wait
```

## What it printed

As shipped (the README's second block, the token in `TIFFINBOX_SHUTDOWNTOKEN`):

```
POST  /shutdown   -> 200 application/json  {"stopping":true}
```

With the token moved (the block above):

```
-rw------- 33 bytes secrets/tiffinbox/shutdown-token
0
POST  /shutdown   -> 200 application/json  {"stopping":true}
```

**33 bytes: the 32-character token and its newline, `-rw-------`. No `TIFFINBOX_` word in `ps eww`. And POST /shutdown
still answers 200** — so the token TiffinBox bound from the file is the header's 32 characters: Boot dropped the newline
(the unit's `where` capture measures the same with the demo token: 27 bytes in the file, 26 in the header, 200).
`grep -c "$TOKEN" tiffinbox.log` gave 0 after both rounds. `secrets/` is git-ignored in the anchor (`../after/.gitignore`,
`secrets/`), and in this repository `.harness/` is.
