# The one duration-word pattern Course 8's builders share. Copied 2026-11-17 (Course 8 set-up) from data-jpa-hibernate/_builders/dur7.py,
# byte for byte in its pattern and its self-test; only this header and the self-test's printed name changed. dur7.py was itself cloned
# 2026-11-01 from spring-web-mvc/_builders/dur6.py (⚑10; RED S6 #511), with one fix: dur6's `milli\w*` also matched "million"
# (Course 6 unit 20's byte count) — there and here `milli(?!on)\w*`.
# Assembled from pieces, so a builder that refuses its own source never trips on the pattern; this module's self-test lists the
# words it must refuse and pass. Run `python3 dur8.py` for the self-test (it also runs on import).
import re
_W = ["quick" + "(ly|er|est)?", "fast" + "(er|est)?", "slow" + "(er|est|ly)?", "late" + "ncy", "spe" + "ed(y|s|ier)?",
      "minut" + "es?", "sec" + "onds", "milli" + r"(?!on)\w*", "m" + "s", r"\d+ ?m" + "s", "lag" + "s?", "snapp" + "y"]
DUR = re.compile(r"\b(" + "|".join(_W) + r")\b", re.I)
for _t in ("quick", "faster", "3 ms", "latency", "seconds", "milliseconds", "millisecond", "ms", "speed", "slowly", "fast"):
    assert DUR.search(_t), _t
for _t in ("breakfast", "steady", "msg", "items", "terms", "30000msx", "lagoon", "the second", "million", "one million rows"):
    assert not DUR.search(_t), _t

if __name__ == "__main__":
    print("dur8 self-test: OK (11 must-match, 10 must-not-match incl. 'million')")
