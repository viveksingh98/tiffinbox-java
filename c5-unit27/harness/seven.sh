#!/bin/sh
# seven.sh PORT TOKENFILE: the comparison set since the secrets lesson - the seven requests, POST /shutdown last with the token's
# header read from TOKENFILE (never a command line) - run against 127.0.0.1:PORT, and the md5 of the seven lines it prints. The
# set itself is the secrets lesson's own file, read from where it lives: nothing of it is copied here.
here=$(cd "$(dirname "$0")" && pwd)
"$here/../../c5-unit11/curlset.sh" "$1" "$2" | md5 -q
