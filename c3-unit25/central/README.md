# central/ — five files, fetched once, committed on purpose

`../receipts.sh actions` derives this unit's version table from these files and **makes no
network request at all**, so the pins can be checked from a clean clone with the wifi off.

| File | Source | Fetched |
|---|---|---|
| `actions-checkout-latest.json` | `api.github.com/repos/actions/checkout/releases/latest` | 2026-09-15 |
| `actions-setup-java-latest.json` | `…/actions/setup-java/releases/latest` | 2026-09-15 |
| `actions-cache-latest.json` | `…/actions/cache/releases/latest` | 2026-09-15 |
| `actions-upload-artifact-latest.json` | `…/actions/upload-artifact/releases/latest` | 2026-09-15 |
| `adoptium-available-releases.json` | `api.adoptium.net/v3/info/available_releases` | 2026-09-15 |

The Adoptium file is what makes the matrix defensible without a date on a slide: it names
the LTS releases and the most recent feature release, so "25 is the baseline and the other
one is a compatibility check" is read off an API rather than remembered.
