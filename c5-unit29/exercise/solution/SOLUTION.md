# Solution — the image, with ten days instead of thirty

Run from `c5-unit29/`, after `exercise/README.md`'s commands. One line: it starts the image with `--tiffinbox.days=10` after the
image name — your own user, the config tree read-only, the port on `127.0.0.1` alone — waits until readiness answers 200, asks
the kitchen, stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file), waits for the
container to exit, removes it, and prints the kitchen's answer.

```bash
cd .harness/mine/after && docker run -d --name tiffinbox-mine --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19159:18425 tiffinbox-mine:1.0.0 --tiffinbox.days=10 > /dev/null && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19159/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && k=$(curl -s http://127.0.0.1:19159/kitchen) && ../../../harness/shutdown.sh 19159 secrets/tiffinbox/shutdown-token > /dev/null && docker wait tiffinbox-mine > /dev/null && docker rm tiffinbox-mine > /dev/null && echo "the kitchen, ten days, in the image: $k"
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-08):

```
the kitchen, ten days, in the image: {"ordersCooked":40,"ordersValue":8100}
```

The option after the image name is what the line tells apart: without it the kitchen cooks 120 (`forms` and `image` read the
image's log: `orders cooked:  120`). A bare number after the image name is refused — exit 2, before TiffinBox listens (the
`fails` capture, D).
