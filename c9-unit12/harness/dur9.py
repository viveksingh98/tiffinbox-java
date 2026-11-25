# The one duration-word pattern Course 9's builders and check_unit9.py share: S9.18 (SETUP-BRIEF-2026-11-23.md §CONTRACT DELTA, as amended by
# BLUE C9-SETUP after RED C9-SETUP #6). Written 2026-11-23 (Course 9 pre-boundary, LANE 7). It is NOT dur8.py renamed: BLUE re-ran RED #6's
# plants through dur8.DUR and every one of them came back False ("The key is kept for a day.", `Retry-After: 30`, ...). So:
#   DUR_WORDS   = dur8.py's pattern, its pieces and its self-test copied byte for byte (spring-data-beyond-jpa/_builders/dur8.py, md5
#                 1ae45ade6730a321cbda96ecfbf6ac9a on 2026-11-23, itself dur7's = dur6's with `milli(?!on)`). Copied, not imported: Course 9's gate
#                 never moves because a Course 8 file moved, and dur8.py stays Course 8's, byte for byte.
#   DUR_PHRASES = S9.18's duration phrases: second, hour, day, week, month, year (singular or plural) after a number word or a / an / one /
#                 per / every / each / for. LANE 7's stricter additions are each a must-match plant below: a digit run ("24 hours"), a
#                 hyphen compound ("a one-day key", "a 30-day key"), few / several / many / a couple of. The domain's near misses pass:
#                 "meals a day" / "meals per day" (TiffinBox's mealsPerDay), "zero days" (pausedDays — "zero" is no trigger), and "second" as
#                 an ordinal ("a second connection", "the second client" — after a / an, "second" followed by a word is the ordinal unless the
#                 word continues a duration: "a second later", "a second and a half").
#   TIMEPAT_S9  = S9.18's header and log forms: max-age=, Retry-After:, Keep-Alive: timeout=, Sunset:, Deprecation: @, \d+(\.\d+)? ?m?s\b, PT\d,
#                 expireAfterWrite=, read-timeout=, Surefire's Time elapsed, Maven's Total time, Flyway's execution time, Boot's Started … in
#                 (+ LANE 7: a spoken number after Retry-After, `timeout=` and `connect-timeout=` on their own, `expireAfterAccess=`). A builder
#                 masks a capture with it (TIMEPAT_S4B's job in Course 8, R.451).
#   DUR         = the union of the three. It is what check_unit9.load_dur() returns, and what every Course 9 builder gates SAY lines and deck
#                 prose with.
# Assembled from pieces, as dur8's is, so a tool that scans this file's pattern source never trips on the words. Run `python3 dur9.py` for the
# self-test (it also runs on import, so a broken edit cannot be imported). The S1 brief's draft dur9 (probe step 10) is reconciled with this file
# before DUR_SECTIONS gates Section 1's first script: both plant lists must match here, and both near-miss lists must pass (TOOLS-README-C9.md).
#
# BLUE C9-TOOLS 2026-11-23 (after RED-C9-TOOLS-2026-11-23.md rows 1-4; TOOLS-README-C9.md §AMENDMENT):
#   * WIDENED (row 3): every bypass RED planted is a must-match plant in PLANTS_BLUE — abbreviated units after a digit or a number word, a rate
#     "/s", micro- and nanoseconds, "a thirty-second timeout", "N more days", "half an hour", a bare plural unit after in / within / takes or
#     before later / ago, "all day", a header or setting name followed by of / is / says / = and a number, ISO-8601 "P1D", Duration.ofSeconds(,
#     a latency percentile — and the label rule no longer applies after a count or a / an ("thirty days one invoice", "a day one more time").
#     The near misses that must still pass are NEAR_MISSES_BLUE (ordinals, status classes, I/O, -Xmx512m, labels, the domain).
#   * PINNED (row 4): this file's md5 is java9_series.DUR9_MD5. check_unit9.py, upload_java9.py and gen_thumbs_java9.py load it only through
#     java9_series.load_dur9(), which REFUSES any other md5, so a one-character weakening fails every gate and every self-test. An edit to this
#     file updates java9_series.DUR9_MD5 in the same change, with its plant. Every alternative of _W, _P and _T is exercised ALONE by a plant
#     (the self-test below), so dropping one, or narrowing it past its plant, fails here first.
#   * THE ALLOWANCE (rows 1-2; S9.9, R.415, ⚑10): ONE table, `_builders/dur9_allow.py` (data only, parsed with ast, never executed), keyed by
#     unit and exact sentence, each value bound to the capture it is read back from. load_allow() / judge() / gate() below are its logic; the
#     builders and check_unit9.py call the same judge(), so a sentence the gate allows is the sentence the builder allowed, and nothing else.
# BLUE ROUND 2 C9-TOOLS 2026-11-23 (RED2-C9-TOOLS-2026-11-23.md #1, #2, #3, #15; TOOLS-README-C9.md §AMENDMENT (BLUE ROUND 2)):
#   * WIDENED (#1): a setting's name and its bare number in one clause ("Retry-After comes back as thirty", "the timeout on the client is two
#     thousand"), and the bare value after try again in / gives up after / waits / goes stale after / a window of — 17 forms, + the two LIVE
#     beats that shipped in that form (C4/28.6, C7/28.4), plants in PLANTS_BLUE2. "is one of …" is a count, never a value (_NUMQ).
#   * THE ALLOWANCE (#3, #15, #2): only the value's phrase and the name ATTACHED to it are exempted (claim_regions); one sentence per 'say'
#     entry; micro/nanoseconds and percentiles are latency; the capture line must name the setting (CAPTURE_TERMS); every entry is judged
#     on the original text before any is masked (adjacent entries); a malformed field is a problem, never a TypeError.
import ast, hashlib, os, re

# ---- dur8.py's words, byte for byte (its `_W`, its compile, its two self-test loops) -------------------------------------------------------
_W = ["quick" + "(ly|er|est)?", "fast" + "(er|est)?", "slow" + "(er|est|ly)?", "late" + "ncy", "spe" + "ed(y|s|ier)?",
      "minut" + "es?", "sec" + "onds", "milli" + r"(?!on)\w*", "m" + "s", r"\d+ ?m" + "s", "lag" + "s?", "snapp" + "y"]
DUR_WORDS = re.compile(r"\b(" + "|".join(_W) + r")\b", re.I)
for _t in ("quick", "faster", "3 ms", "latency", "seconds", "milliseconds", "millisecond", "ms", "speed", "slowly", "fast"):
    assert DUR_WORDS.search(_t), _t
for _t in ("breakfast", "steady", "msg", "items", "terms", "30000msx", "lagoon", "the second", "million", "one million rows"):
    assert not DUR_WORDS.search(_t), _t

# ---- S9.18's duration phrases -------------------------------------------------------------------------------------------------------------
_ONES = "one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen"
_TENS = "twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety"
_NUM = _ONES + "|" + _TENS + "|hundred|thousand|million"                # "zero" is NOT a trigger: "zero days" is pausedDays, a count
_DIG = r"\d+(?:\.\d+)?"
# every unit but the second (BLUE C9-TOOLS adds fortnight, decade, century: "a fortnight", "a decade")
_LONG = "(?:h" + "ours?|d" + "ays?|w" + "eeks?|m" + "onths?|y" + "ears?|fortn" + "ights?|dec" + "ades?|centur" + "(?:y|ies))"
_LONGP = "(?:h" + "ours|d" + "ays|w" + "eeks|m" + "onths|y" + "ears|fortn" + "ights|dec" + "ades|minut" + "es|sec" + "onds)"   # plural, every unit
_SEC = "sec" + "ond"
_MIN = "minut" + "es?"
# After a / an, "second" + a word is the ordinal ("a second connection"), unless the word continues a duration ("a second later").
_CONT = ("and|or|later|ago|earlier|apart|long|longer|more|less|of|to|in|on|at|is|was|before|after|too|then|per|each|every|the|that|which|"
         "while|when|until|till|so|but|for|from|between|since|here|there|it|this")
_MEALS = r"(?<!meals )(?<!meal )"                                       # TiffinBox's "two meals a day" / "meals per day" (mealsPerDay)
# A unit followed by a number is a calendar label, not a length: Course 6's "Ask for week nine" (U25:102, U27:85, spoken), Course 8's
# "day nineteen" (measured by LANE 7 over Courses 6-8's spoken lines, 2026-11-23 — the label class of S9.18's ordinal "second").
# BLUE C9-TOOLS: the label rule applies only after per / every / each / for. After a count or a / an it is a length whatever follows
# ("thirty days one invoice", "kept for a day one more time" were RED C9-TOOLS #3's bypasses of it).
_LABEL = r"(?![\s-]+(?:" + "zero|" + _NUM + r"|\d))"
# a duration noun after a tens-second compound ("the sixty-second window" is a length; "the twenty-second request" stays an ordinal)
_DNOUN = ("time" + "outs?|windows?|waits?|delays?|limits?|life" + "times?|ttls?|keys?|cache|expir(?:y|ies)|intervals?|pauses?|retry|retries|"
          "backoffs?|periods?|grace|deadlines?|budgets?|heartbeats?|polls?|leases?|locks?|tokens?|sessions?|cool-?downs?|caps?|buckets?")
_P = [
    r"\b(?:" + _NUM + "|" + _DIG + r")(?:\s+|-)" + _LONG + r"\b",   # "two days", "24 hours", "a one-day key", "a 30-day key" (no label rule: a count)
    r"\b(?:" + _ONES + "|" + _DIG + r")(?:\s+|-)" + _SEC + r"s?\b",          # "one second", "1 second", "a five-second wait" (tens + -second = ordinal)
    _MEALS + r"\b(?:a|an|few|several|many|a couple of|couple of)\s+" + _LONG + r"\b",   # "a day", "an hour", "a few days" (no label rule)
    _MEALS + r"\b(?:per|every|each|for)\s+(?:" + _SEC + "s?|" + _LONG + r")\b" + _LABEL,     # "per second", "every hour", "for days"
    # "a second." / "a second later" — not "a second write", nor the ordinal compound "a second-level cache" (C8-3's pinned sentence, U12)
    r"\b(?:a|an)\s+" + _SEC + r"\b(?![\s-]+(?!(?:" + _CONT + r")\b)[a-z])",
    # ---- BLUE C9-TOOLS (RED C9-TOOLS #3), each alternative a plant in PLANTS_BLUE ----
    r"\b" + _DIG + r"[\s-]?(?:secs?|mins?|hrs?|wks?|yrs?|[mun]secs?|ns|us|µs|μs|h|d|m)\b",   # "1 sec", "24h", "a 30d bill", "TTL 10m", "120 ns"
    r"\b(?:" + _NUM + r")[\s-]+(?:secs?|mins?|hrs?|wks?|yrs?|[mun]secs?)\b",   # "two secs", "five mins", "three hrs"
    r"\b(?:a|an|per|every|each)\s+(?:secs?|hrs?)\b",                          # "a sec later", "per sec"
    r"\b[mun]secs?\b",                                                       # "msec", "5 msecs" (the abbreviation alone)
    r"(?<=[\w)])/(?:s|secs?|m|mins?|h|hrs?|d)\b",                             # a rate: "100 req/s", "ten requests/sec" (not and/or, I/O, TCP/IP)
    r"\b(?:micro|nano)[\s-]?" + _SEC + r"s?\b",                               # "four hundred microseconds", "one nanosecond"
    r"\b(?:a|an)\s+(?:" + _TENS + r")[\s-]+" + _SEC + r"\b",                  # "a thirty-second timeout" ("the twenty-second request" = ordinal)
    r"\b(?:" + _TENS + r")[\s-]+" + _SEC + r"[\s-]+(?:" + _DNOUN + r")\b",    # "the sixty-second window"
    r"\b(?:" + _NUM + "|" + _DIG + r")\s+(?:more|extra|further|additional|whole|full|long|straight|consecutive|calendar|business|working)\s+(?:"
    + _LONG + "|" + _SEC + "s?|" + _MIN + r")\b",                             # "it answers for thirty more days"
    r"\b(?:half|quarter)(?:\s+(?:of\s+)?an?)?[\s-]+(?:" + _LONG + "|" + _SEC + "s?|" + _MIN + r")\b",   # "two and a half hours", "a quarter hour"
    r"\b(?:in|within|takes?|took|taking|lasts?|lasted|lasting|over|under|about|around|nearly|almost|only|just|some|spends?|spent|waits?|waited)\s+"
    + _LONGP + r"\b",                                                         # "within days", "it takes weeks", "in hours, not days"
    r"\b" + _LONGP + r"\s+(?:later|ago|earlier|apart|on\s+end|from\s+now|long|old|back)\b",   # "hours later", "days ago"
    r"\ball\s+(?:day|night|week|month|year)\b|\b(?:whole|entire|full)\s+(?:" + _LONG + "|" + _SEC + "s?|" + _MIN
    + r")\b|\b(?:over|through)night\b|\b(?:day|hour|week|month|year|minute)[\s-]long\b",     # "the cache lasts all day", "overnight"
]
DUR_PHRASES = re.compile("|".join("(?:" + p + ")" for p in _P), re.I)

# ---- TIMEPAT_S9: header and log forms --------------------------------------------------------------------------------------------------
_NUMW0 = "zero|" + _NUM
# BLUE C9-TOOLS: a header or setting NAME, then of / is / says / = / : and a number — "the Retry-After header says thirty", "max-age of 3600",
# "read timeout of two", "Keep-Alive timeout 60", "a TTL of ten". The name alone ("the Retry-After header", "the read timeout") still passes.
_HDR = (r"(?:Retry[\s-]?After|s-?maxage|max[\s-]?age|Sunset|Keep[\s-]?Alive(?:\s+time" + r"[\s-]?out)?|(?:read|connect|connection|socket|"
        r"response|request|idle|call|write)[\s-]+time" + r"[\s-]?out|time" + r"[\s-]?out|TTL|time[\s-]to[\s-]live|expireAfter(?:Write|Access)|"
        r"Age\s+header)")
_LIFE = r"(?:life" + r"[\s-]?time|expir(?:y|es|ation)|Expires)"
_HNOUN = r"(?:\s+(?:header|value|directive|setting|property|field|line|parameter))?"
_NUMV = r"(?:\d|(?:" + _NUMW0 + r")\b)"
_NUMQ = _NUMV + r"(?![\s-]+of\b)"
_CONN = r"(?:of|is|was|says|said|reads|equals|becomes|stays|set|to|now|still|just|only|exactly|about|=)"
# BLUE ROUND 2: every setting name a value can follow (the headers, the timeouts, TTL, lifetime / expiry, and the retry family's delay,
# backoff, interval, lease, grace period, cool-down); the verbs that hand it its value; a number that is not "one of …" (a count).
_SETTING = (r"(?:" + _HDR + "|" + _LIFE + r"|(?:fixed[\s-]?|initial[\s-]?)?delay|back[\s-]?off|interval|lease|grace\s+period|"
            r"cool-?down)")
_VALW = (r"(?:is|was|says|said|reads|read|holds|held|equals|becomes|became|stays|stayed|sits\s+at|sat\s+at|comes?\s+back\s+(?:as|at)|"
         r"came\s+back\s+(?:as|at)|(?:is\s+)?set\s+to)")
_CONNL = r"(?:is|was|says|said|set|to|now|still|just|only|exactly|=)"
_T = [
    r"\bmax-age\s*=",                                                   # S9.18's form, whatever the value
    r"\bmax-age\s+(?:\d|(?:" + _NUMW0 + r")\b)",                        # LANE 7: spoken, "max-age thirty"
    r"\bs-maxage\s*=",                                                  # LANE 7: the shared-cache twin
    r"\bRetry-After\s*:",                                               # S9.18's form: seconds OR an HTTP date ("Retry-After: Wed, 21 Oct …")
    r"\bRetry-After\s+(?:\d|(?:" + _NUMW0 + r")\b)",                    # LANE 7: spoken, "Retry-After thirty"
    r"\bExpires\s*:", r"\bAge\s*:\s*\d",                                # LANE 7: the other duration-valued cache headers
    r"\bKeep-Alive\s*:\s*time" + r"out\s*=\s*\d",
    r"\btime" + r"out\s*=\s*\d",
    r"\bSunset\s*:",
    r"\bDeprecation\s*:\s*@",
    r"\d+(?:\.\d+)? ?m?s\b",
    r"\bPT\d",
    r"\bexpireAfter(?:Write|Access)\s*=\s*\d",
    r"\bread-time" + r"out\s*=",
    r"\bconnect-time" + r"out\s*=",
    r"\bTime elap" + r"sed\b",
    r"\bTotal ti" + r"me\b",
    r"\bexecution ti" + r"me\b",
    r"\bStarted \S+ in \d",
    # ---- BLUE C9-TOOLS (RED C9-TOOLS #3), each alternative a plant in PLANTS_BLUE ----
    r"\b" + _HDR + _HNOUN + r"(?:\s*[:=]\s*|(?:\s+" + _CONN + r"){1,3}\s+)" + _NUMQ,   # "the Retry-After header says thirty", "max-age of 3600"
    r"\b" + _HDR + _HNOUN + r"\s+\d",                                                    # "Keep-Alive timeout 60", "socket timeout 30"
    r"\b" + _LIFE + _HNOUN + r"(?:\s*[:=]\s*|(?:\s+" + _CONNL + r"){1,3}\s+)" + _NUMQ,  # "the lifetime is thirty", "the expiry is five"
    r"\b(?:Sunset|expir(?:es|y|ation)|Retry[\s-]?After)\s+in\s+" + _NUMV,                # "Sunset in thirty", "expires in five"
    r"\bmax[\s-]age\s+" + _NUMV + r"|\bmax\s+age\s+" + _NUMV,                           # "max age thirty" (spoken, no hyphen)
    r"\bRetry\s+After\s+" + _NUMV,                                                       # "Retry After thirty" (no hyphen)
    r"\bPT?\d+(?:\.\d+)?[SMHDWY]",                                                       # ISO-8601: "P1D", "P30D", "pt10m"
    r"\bof(?:Nanos|Millis|Seconds|Minutes|Hours|Days|Weeks|Months|Years)\s*\(",          # "Duration.ofSeconds(30)", "ofDays(1)"
    r"\bp(?:50|75|90|95|99|999)\b",                                                      # a latency percentile, "the p99" (R3)
    # ---- BLUE ROUND 2 C9-TOOLS (RED2-C9-TOOLS #1): a setting's NAME and its bare number in one clause, and the bare value after "try again
    # in", "gives up after", "waits", "goes stale after", "a window of" — 17 forms RED2 showed passing end to end, each a plant below ----
    r"\b" + _SETTING + r"\b[^.!?;]{0,40}?(?:(?<![\w-])" + _VALW + r"\s+|\s*[:=]\s*)" + _NUMQ,   # "the timeout on the client is two thousand"
    r"\b(?:(?:try|tries|tried|ask|asks|asked|retry|retries|retried)(?:\s+(?:again|back))?|(?:come|comes|came|call|calls|called|check|checks|"
    r"checked|poll|polls|polled)\s+(?:again|back))\s+(?:in|after)\s+" + _NUMQ,                      # "try again in thirty", "retry in thirty"
    r"\b(?:gives?|gave|giving)\s+up\s+after\s+" + _NUMQ + r"|\bwait(?:s|ed|ing)?\s+" + _NUMQ,       # "gives up after two thousand", "waits three hundred"
    r"\b(?:stale|fresh)\s+(?:after|for|until|in)\s+" + _NUMQ + r"|\bvalid\s+(?:until|after)\s+" + _NUMQ
    + r"|\bexpir(?:es|ed|y)\s+after\s+" + _NUMQ,                                                     # "goes stale after thirty"
    r"\bwindows?\s+of\s+" + _NUMQ + r"(?![\s-]+(?:requests?|calls?|tokens?|items?|entries|hits?|answers?)\b)",   # "a window of sixty"
]
TIMEPAT_S9 = re.compile("|".join("(?:" + t + ")" for t in _T), re.I)

DUR = re.compile("|".join("(?:" + rx.pattern + ")" for rx in (DUR_WORDS, DUR_PHRASES, TIMEPAT_S9)), re.I)

# ---- the self-test: RED C9-SETUP #6's plants must match, the domain's near misses must not ------------------------------------------------
PLANTS = (  # S9.18 / RED #6, verbatim — each must match DUR
    "The key is kept for a day.", "Ten requests an hour, per key.", "A year is safe for a versioned name.", "Try again in one second.",
    "Retry-After: 30", "max-age=31536000", "Keep-Alive: timeout=60", "Time elapsed: 3.982 s", "Total time:  12.345 s",
    "(execution time 00:00.023s)",
)
PLANTS_LANE7 = (  # LANE 7's additions (each a form the rule's words cover, or a stricter one) — each must match DUR
    "expireAfterWrite=10m", "read-timeout=1s", "connect-timeout=2s", "Retry-After: 0", "Retry-After thirty", "max-age=0", "PT10M",
    "Retry-After: Wed, 21 Oct 2026 07:28:00 GMT", "max-age thirty", "s-maxage=600", "Expires: Thu, 01 Dec 2026 16:00:00 GMT", "Age: 30",
    "Deprecation: @1735689600", "Sunset: Thu, 31 Dec 2026 23:59:59 GMT", "Started TiffinBoxApp in 2.104 seconds", "timeout=60",
    "a one-day key", "a 30-day key", "within 24 hours", "twenty-four hours", "for days", "a couple of hours", "several weeks",
    "a few days", "per second", "every hour", "each day", "half a second.", "wait a second, then retry", "a second later",
    "a second and a half", "two days", "a month", "five years", "1 second", "a five-second wait", "12 ms", "3.5s",
    "two days, three hours", "for a week. Nine requests later", "the two-second key", "a year's lifetime", "a one-second read timeout",
)
PLANTS_BLUE = (  # BLUE C9-TOOLS: every bypass RED C9-TOOLS #3 planted (dur9_probe, spine_probe, e2e_plants), verbatim, + one per alternative
    # RED #3's list, verbatim
    "try again in 1 sec", "two secs", "100 req/s", "the key lives 24h", "a 30d bill", "TTL 10m", "expires in 5 min", "a 5-min window",
    "2 hrs", "the timer records nanoseconds", "120 ns", "120 us", "5 msecs", "a thirty-second timeout", "a sixty-second window",
    "hours later", "within days", "it takes weeks", "the cache lasts all day", "the Retry-After header says thirty", "Retry-After of twelve",
    "Retry After thirty", "max-age of 3600", "max-age is sixty", "Sunset in thirty", "Keep-Alive timeout 60", "read timeout of two", "P1D",
    "P30D", "two and a half hours", "kept for a day one more time", "it answers for thirty more days",
    # RED #3's end-to-end lines through check_unit9.main(), verbatim
    "The Retry-After header says thirty, so try again then.", "The window is a sixty-second window.",
    "The timer recorded four hundred microseconds.", "Ask again in 1 sec, the key lives 24h.", "TTL 10m · expires in 15 min",
    # RED's probe candidates of the same forms (dur9_probe.py)
    "wait one sec", "a sec later", "per sec", "ten requests/sec", "cache it for 1h", "two mins", "a 2hr window", "3 yrs", "two wks",
    "in microseconds", "one nanosecond", "msec", "a ninety-second wait", "a twenty-second delay", "in hours, not days", "days later",
    "the whole day", "overnight", "a fortnight", "a decade", "a Retry-After of 30", "max age thirty", "a TTL of ten",
    "expireAfterWrite of ten", "a thirty day sunset", "thirty days one invoice", "half an hour", "a quarter hour", "a connect timeout of 2",
    "PT1H", "pt10m", "Duration.ofSeconds(30)", "Duration.ofMinutes(10)", "ofDays(1)", "1.5 hours", "twenty four hours",
    # BLUE: the forms' siblings, and one plant for each inherited alternative (RED C9-TOOLS #4: "a minute", "lags", "snappy" first)
    "a minute", "five minutes", "ten requests a minute", "a five-minute window", "lags", "it lags", "snappy", "speedy", "speeds", "speedier",
    "quickly", "quicker", "quickest", "fastest", "slower", "slowest", "millis", "the p99", "120 µs", "the lifetime is thirty",
    "the latency", "the speed", "fast", "ms", "seconds", "milliseconds", "3 ms",
    "the expiry is five", "expires in five", "the Age header says thirty", "s-maxage of 600", "an idle timeout of ten", "socket timeout 30",
    "the sixty-second window", "a day-long wait", "days ago", "years old", "for three more weeks", "three extra hours",
)
NEAR_MISSES = (  # S9.18 / RED #6 + BLUE's measured near misses (Courses 6-8's spoken lines), verbatim — none may match DUR
    "meals a day", "meals per day", "zero days", "a second connection", "the second client", "a second write", "the second request",
    "a second try", "pausedDays", "mealsPerDay", "/menu/{day}", "a second pass", "a second read", "a second start",
)
NEAR_MISSES_LANE7 = (  # LANE 7's: ordinals, compounds, header names alone, status classes, the domain — none may match DUR
    "the twenty-second request", "a second JVM", "a second TiffinBox", "a second time", "the second write", "two meals a day",
    "A second-level cache holds what Hibernate last read or wrote", "Ask for week nine", "the menu for day nineteen", "every day 19",
    "Monday", "today", "dayOfWeek", "hourly", "daily", "4xx", "5xx", "status 429", "HTTP/1.1", "the Retry-After header",
    "the Sunset header", "the max-age directive", "the Expires header", "a customer's age", "Deprecation: true", "a timeout",
    "the read timeout", "every customer", "each request", "for every route", "one key", "a key", "the seven", "seventy-eight entities",
)
NEAR_MISSES_BLUE = (  # BLUE C9-TOOLS: what the widened forms must still pass — ordinals, status classes, I/O, tokens, labels, the domain
    "the thirty-second unit", "the twenty-second customer", "TCP/IP", "and/or", "read/write", "I/O", "4xx/5xx", "1st", "2nd", "3rd", "4th",
    "the 2xx class", "x86", "-Xmx512m", "H2", "S3", "md5", "sha256", "UTF-8", "IPv4", "P2P", "on day one", "days of the week",
    "the kitchen's opening hours", "the days the kitchen is closed", "two timeouts and three retries", "the timeout fired three times",
    "one timeout, two retries", "Retry-After is a header", "the lifetime of a key", "a key's lifetime", "the expiry date",
    "the timeout is the stub's", "a quarter of the meals", "half the meals", "the full menu", "a whole customer", "a min and a max",
    "weekly", "the twenty-second request", "Ask for week nine", "every day 19", "a second connection", "a second-level cache",
    "/customers/{name}", "the U-R-L ends in slash s", "two meals a day", "pausedDays", "mealsPerDay", "Spring Boot 4.1.2", "JDK 25",
    "four oh four", "two hundred and one statements", "one hundred and twenty orders",
)
PLANTS_BLUE2 = (  # BLUE ROUND 2 C9-TOOLS: RED2-C9-TOOLS #1's 17 forms, verbatim, the two shipped beats it found, and siblings
    "The Retry-After header on that answer says thirty.", "Retry-After comes back as thirty.",
    "The answer carries Retry-After, and its value is thirty.", "Retry-After, the header, says thirty.", "The Retry-After it sends back is thirty.",
    "The header Retry-After holds thirty.", "The stylesheet's max-age on that answer is thirty-one million.",
    "Cache-Control says the stylesheet stays fresh for thirty-one million five hundred thousand.", "The cached menu goes stale after thirty.",
    "The client gives up after two thousand.", "The client waits two thousand before it gives up.", "The timeout on the client is two thousand.",
    "The client's timeout sits at two thousand.", "Retry in thirty.", "Try again in thirty.", "Ask again after thirty.",
    "Ten requests per rolling window of sixty.",
    # shipped (Course 4 U28 :6, Course 7 U28 :4 — LIVE; information only, never re-cut), verbatim
    "Fixed delay waits three hundred after the job finishes. So the gap is the wait plus the work — about five hundred.",
    "The lock timeout hint: zero gives no wait. One thousand gives H two's clause, wait one, and on Postgres a lock timeout set around the read.",
    # siblings of the same forms
    "The client reads Retry-After: it is thirty.", "The read timeout is set to two thousand.", "The backoff on the second attempt is two hundred.",
    "The fixed delay sat at three hundred.", "Come back after sixty.", "It retried after two hundred.", "The token is valid until ninety.",
    "The link expires after nine hundred.", "A window of sixty, ten requests in it.", "The connect timeout came back as two thousand.",
)
NEAR_MISSES_BLUE2 = (  # BLUE ROUND 2: what the round-2 forms must still pass (each measured over the corpus too)
    "Retry-After is one of the headers a four twenty-nine carries.", "The timeout is one of three settings.", "a window of ten requests",
    "It comes in four levels, and five anomalies show what each one lets through.", "Try it in two terminals.",
    "the interval between two requests", "the timeout fired three times", "Retry-After is a header", "the delay is the stub's",
    "The Retry-After header names the wait.", "the read timeout", "a lease", "the grace period", "it waits for two answers",
    "ask again after the window", "a client that gives up", "the stale entry", "Retry-After, the header, is the one the client reads.",
)
for _t in PLANTS + PLANTS_LANE7 + PLANTS_BLUE + PLANTS_BLUE2:
    assert DUR.search(_t), ("dur9 plant must match", _t)
for _t in NEAR_MISSES + NEAR_MISSES_LANE7 + NEAR_MISSES_BLUE + NEAR_MISSES_BLUE2:
    assert not DUR.search(_t), ("dur9 near miss must pass", _t, DUR.search(_t).group(0))
# Each of the three parts carries its own share (a union whose parts were never exercised alone could hide a dead branch):
assert not DUR_WORDS.search("The key is kept for a day.") and DUR_PHRASES.search("The key is kept for a day.")
assert not DUR_WORDS.search("Retry-After: 30") and not DUR_PHRASES.search("Retry-After: 30") and TIMEPAT_S9.search("Retry-After: 30")
assert DUR_WORDS.search("seconds") and not DUR_PHRASES.search("the second client") and not TIMEPAT_S9.search("the second client")
# BLUE C9-TOOLS (RED C9-TOOLS #4): EVERY alternative of _W, _P and _T, alone, matches at least one plant — so a copy that drops one, or
# narrows it past its plant ("minut" + "es" for "es?"), fails here. The md5 pin (java9_series.DUR9_MD5) refuses every other edit.
_ALL_PLANTS = PLANTS + PLANTS_LANE7 + PLANTS_BLUE + PLANTS_BLUE2
for _name, _alts, _wrap in (("_W", _W, lambda a: r"\b(" + a + r")\b"), ("_P", _P, lambda a: a), ("_T", _T, lambda a: a)):
    for _i, _a in enumerate(_alts):
        _rx = re.compile(_wrap(_a), re.I)
        assert any(_rx.search(_t) for _t in _ALL_PLANTS), ("dur9: an alternative no plant exercises (a weakening would pass)", _name, _i, _a[:60])


def words(text):
    """Every dur9 hit in `text`, lower-cased, de-duplicated, with the milli-but-not-time matches dropped — check_unit9.dur_words()'s reading,
    for a builder (check_unit9's self-test asserts the two agree)."""
    out = set()
    for m in DUR.finditer(text):
        w = m.group(0).lower()
        if w.startswith("milli") and not re.match(r"^milli(s|sec\w*)?$|^millisecond\w*$", w, re.I):
            continue
        out.add(w)
    return sorted(out)


# ---- S9.9's ALLOWANCE (BLUE C9-TOOLS; RED C9-TOOLS #1-#2) ---------------------------------------------------------------------------------
# A duration-valued setting or header (S9.9) may be voiced ONLY through one entry of `_builders/dur9_allow.py`'s ALLOW table:
#   ALLOW = {"NN": ({"where": "say" | "deck", "text": <the exact sentence or deck cell>, "kind": <one of KINDS>, "capture": ".r-NAME.out",
#                    "line": <regex matching ONE line of that capture, group (?P<v>…) = the value as printed>, "says": <the value as the
#                    text says it: number words or digits>, "unit": <"second" … "year", or None for a bare header value>,
#                    "capture_unit": <"ms" | "s" | "m" | "h" | "d" | "w", or None>}, …), …}
# An entry holds only when ALL of these hold, every run, by the builder and by check_unit9 (judge() below):
#   * it is unit NN's (a sentence allowed in 04 is refused in 05), and its text occurs EXACTLY ONCE in that unit's SAY lines (a whole
#     sentence) or deck prose (a whole cell);
#   * dur9 fires on the text (R.415: shown firing first), the text names what is configured (its KINDS term), and it holds no latency word
#     (R3: a latency is never voiced);
#   * every dur9 hit in the text lies in the value's own phrase or its header's name beside it (a second, unbacked duration in an allowed
#     sentence is refused);
#   * the capture `c9-unitNN/.r-NAME.out` exists (a regular file), its md5 equals the `NAME` line of `c9-unitNN/receipts.md5` (the published
#     run of record), `line` matches exactly one of its lines, and that line's value equals what the text says (with `unit` / `capture_unit`
#     converting: "a day" against `PT24H`);
# Otherwise the entry is a PROBLEM (the gate FAILS) and its sentence is not exempted, so its words fail as well. A copy line, a title or a
# thumbnail takes no allowance: they name the header, never its value.
KINDS = {  # S9.9's duration-valued settings and headers (+ S9.13's time to live), each with the term its sentence must name
    "timeout": r"time[\s-]?outs?|Keep[\s-]?Alive",
    "Retry-After": r"Retry[\s-]?After",
    "max-age": r"s-?maxage|max[\s-]?age|Cache-Control",
    "key lifetime": r"life[\s-]?time|kept|keeps|lives|expir\w*",
    "time to live": r"TTL|time[\s-]to[\s-]live|expireAfter\w*",
    "expiry": r"expir\w*",
    "Sunset": r"Sunset",
    "Deprecation": r"Deprecation",
    "backoff": r"back[\s-]?off|delay\w*",
}
# BLUE ROUND 2 (RED2-C9-TOOLS #3): the term the CAPTURE LINE must carry, per kind — the value is read off the setting's or header's own line,
# never off any line that happens to print the same number ("30 tests run" backed "Retry-After … thirty").
CAPTURE_TERMS = {
    "timeout": r"time[\s-]?out|Keep-Alive",
    "Retry-After": r"Retry-After",
    "max-age": r"max-age|s-maxage",
    "key lifetime": r"ttl|time[\s-]?to[\s-]?live|life[\s-]?time|expir|retention",
    "time to live": r"ttl|time[\s-]?to[\s-]?live|expireAfter",
    "expiry": r"expir",
    "Sunset": r"Sunset",
    "Deprecation": r"Deprecation",
    "backoff": r"back[\s-]?off|delay|interval",
}
# BLUE ROUND 2 (RED2 #3): micro- and nanoseconds and a percentile are latency units in this course — no configured value is written in them.
# Milliseconds and seconds stay allowed as the units of a configured value (a 500 ms connect timeout is S9.9's); an UNBACKED "12 ms" in an
# allowed sentence is refused anyway, because only the value's own phrase is exempted (entry_problems below).
LATENCY = re.compile(r"\b(?:took|takes|taking|elapsed|latenc\w*|fast(?:er|est)?|slow(?:er|est|ly)?|quick(?:ly|er|est)?|speed\w*|snapp\w*|"
                     r"lag(?:s|ged|gy)?|(?:micro|nano)[\s-]?seconds?|[µμun]s|p\d\d+|p-(?:fifty|ninety)\w*)\b", re.I)
_FIELDS = ("where", "text", "kind", "capture", "line", "says", "unit", "capture_unit")
_STR_FIELDS = ("where", "text", "kind", "capture", "line", "says")
_UNIT_S = {"second": 1, "minute": 60, "hour": 3600, "day": 86400, "week": 604800, "year": 31536000}
_CAP_UNIT = {"ms": 0.001, "s": 1, "m": 60, "h": 3600, "d": 86400, "w": 604800}
_NW = {w: i for i, w in enumerate(("zero " + _ONES.replace("|", " ")).split())}
_NW.update({w: (i + 2) * 10 for i, w in enumerate(_TENS.split("|"))})
# a sentence end inside a 'say' entry: . ! or ? (and closing quotes) followed by a space and a capital, a digit or an opening quote
_INNER_END = re.compile(r"[.!?][\"”’')\]]*\s+[A-Z0-9\"“‘'(]")
# the header's NAME attached to the value: the name, an optional header noun, then nothing but ':', '=' or 1-3 connectors before the value
_ATTACH = r"(?:\s+(?:header|value|directive|setting|property|field|line|parameter))?(?:\s*[:=]\s*|(?:\s+" + _CONN + r"){1,3}\s+)$"


def number_value(says):
    """The number a value phrase says: digits ("30", "1.5"), a / an / one, or English number words ("thirty", "twenty-four", "one hundred
    and twenty"). None when it is neither (an entry with an unreadable value is a problem, never a pass)."""
    if not isinstance(says, str):
        return None
    s = says.strip().lower()
    if re.fullmatch(r"\d+(?:\.\d+)?", s):
        return float(s)
    if s in ("a", "an"):
        return 1.0
    total = cur = 0; seen = False
    for w in re.split(r"[\s-]+", s):
        if w == "and" and seen:
            continue
        if w in _NW:
            cur += _NW[w]
        elif w == "hundred":
            cur = (cur or 1) * 100
        elif w == "thousand":
            total += (cur or 1) * 1000; cur = 0
        else:
            return None
        seen = True
    return float(total + cur) if seen else None


def _value_rx(e):
    v = r"(?<![\w-])" + re.escape(e["says"])
    return re.compile(v + (r"[\s-]+" + e["unit"] + r"s?\b" if e["unit"] else r"(?![\w-])"), re.I)


def claim_regions(e):
    """The spans an entry may exempt in its own text: each occurrence of the value's phrase, widened to the header's or setting's NAME only
    when that name is attached to it (BLUE ROUND 2, RED2 #3: a KINDS term up to 80 chars before the value carried everything between)."""
    t, out = e["text"], []
    for m in _value_rx(e).finditer(t):
        s = m.start()
        att = re.search(r"(?:" + KINDS[e["kind"]] + r")" + _ATTACH, t[:s], re.I)
        out.append((att.start() if att else s, m.end()))
    return out


def entry_problems(e):
    """Everything wrong with one ALLOW entry that needs no file: its shape and types, its sentence and its claim. [] when it holds. Never
    raises: a malformed entry (a list where a string belongs) is a problem, so the gate FAILS and writes its receipt (RED2 #2)."""
    if not isinstance(e, dict) or set(e) != set(_FIELDS):
        return [f"an entry has exactly the fields {_FIELDS}, got {sorted(map(str, e)) if isinstance(e, dict) else type(e).__name__}"]
    bad = [k for k in _STR_FIELDS if not isinstance(e[k], str)] + [k for k in ("unit", "capture_unit")
                                                                    if e[k] is not None and not isinstance(e[k], str)]
    if bad:
        return [f"field(s) {bad} must be strings (unit and capture_unit: a string or None) — got "
                + ", ".join(f"{k}={type(e[k]).__name__}" for k in bad)]
    p, t = [], e["text"]
    if e["where"] not in ("say", "deck"):
        p.append(f"where {e['where']!r} is neither 'say' nor 'deck'")
    if e["kind"] not in KINDS:
        p.append(f"kind {e['kind']!r} is not one of S9.9's {sorted(KINDS)}")
    if not t.strip() or t != t.strip():
        return p + ["its text is a non-empty string with no outer spaces"]
    if e["where"] == "say" and not re.fullmatch(r"[A-Z0-9\"“‘'(].*[.!?][\"”’')]*", t, re.S):
        p.append("a 'say' entry is one whole sentence: a capital (or digit) first and . ! or ? last")
    if e["where"] == "say" and _INNER_END.search(t):
        p.append(f"a 'say' entry is ONE sentence — it holds a sentence end inside ({_INNER_END.search(t).group(0)!r})")
    if LATENCY.search(t):
        p.append(f"it holds a latency word ({LATENCY.search(t).group(0)!r}): a latency is never voiced (R3, S9.9)")
    if not DUR.search(t):
        p.append("dur9 does not fire on it: an allowance for a sentence the gate already passes is dead (R.415, shown firing first)")
    if e["kind"] in KINDS and not re.search(KINDS[e["kind"]], t, re.I):
        p.append(f"it never names what is configured (kind {e['kind']!r} needs /{KINDS[e['kind']]}/ in the text)")
    if not re.fullmatch(r"\.r-[A-Za-z0-9][A-Za-z0-9_.-]*\.out", e["capture"]):
        p.append(f"capture {e['capture']!r} is not a receipt capture name (.r-NAME.out)")
    try:
        if "v" not in re.compile(e["line"]).groupindex:
            p.append("its line pattern has no (?P<v>…) group for the printed value")
    except re.error as x:
        p.append(f"its line pattern does not compile ({x})")
    if number_value(e["says"]) is None:
        p.append(f"says {e['says']!r} is neither digits nor number words")
    if e["unit"] is not None and e["unit"] not in _UNIT_S:
        p.append(f"unit {e['unit']!r} is not one of {sorted(_UNIT_S)} or None")
    if e["capture_unit"] is not None and e["capture_unit"] not in _CAP_UNIT:
        p.append(f"capture_unit {e['capture_unit']!r} is not one of {sorted(_CAP_UNIT)} or None")
    if (e["unit"] is None) != (e["capture_unit"] is None):
        p.append("unit and capture_unit are both None (a bare header value) or both set (a converted value)")
    if p:
        return p
    regions = claim_regions(e)
    if not regions:
        return [f"its text never says the value {e['says']!r}" + (f" {e['unit']}" if e["unit"] else "")]
    masked = t
    for a, b in sorted(regions, reverse=True):
        masked = masked[:a] + " ¶ " + masked[b:]
    loose = words(masked)
    if loose:
        p.append(f"it says a duration the capture does not back: {loose} (only the value {e['says']!r} and the name attached to it "
                 f"may be exempted)")
    return p


def capture_problems(e, code_dir):
    """The entry's tie to its capture, read now: present, published (receipts.md5), ONE line that names the setting or header (CAPTURE_TERMS)
    and prints the value, the same value. [] when it holds."""
    cap = os.path.join(code_dir, e["capture"])
    if os.path.islink(cap) or not os.path.isfile(cap):
        return [f"its capture {e['capture']} is not a file in {code_dir} — a value is read back from a capture that exists (S9.9)"]
    raw = open(cap, "rb").read()
    name = e["capture"][len(".r-"):-len(".out")]
    pub = {}
    try:
        for l in open(os.path.join(code_dir, "receipts.md5"), encoding="utf-8"):
            f = l.split()
            if len(f) == 2:
                pub[f[0]] = f[1]
    except OSError as x:
        return [f"receipts.md5 cannot be read ({x.__class__.__name__}) — an allowed value is read back from the published run of record"]
    if pub.get(name) != hashlib.md5(raw).hexdigest():
        return [f"{e['capture']}'s md5 {hashlib.md5(raw).hexdigest()[:8]}… is not receipts.md5's {name!r} line ({str(pub.get(name))[:8]}…)"]
    rx = re.compile(e["line"])
    lines = [l for l in raw.decode("utf-8", "replace").splitlines() if rx.search(l)]
    if len(lines) != 1:
        return [f"its line pattern matches {len(lines)} lines of {e['capture']} — exactly one is the value's line"]
    if not re.search(CAPTURE_TERMS[e["kind"]], lines[0], re.I):
        return [f"the matched capture line {lines[0][:60]!r} does not name the {e['kind']} (/{CAPTURE_TERMS[e['kind']]}/) — the value is read "
                f"off the setting's or header's own line"]
    try:
        got = float(rx.search(lines[0]).group("v"))
    except (TypeError, ValueError):
        return [f"the capture's value {rx.search(lines[0]).group('v')!r} is not a number"]
    want = number_value(e["says"]) * (_UNIT_S[e["unit"]] / _CAP_UNIT[e["capture_unit"]] if e["unit"] else 1)
    if abs(got - want) > 1e-9 * max(1.0, abs(want)):
        return [f"the text says {e['says']!r}" + (f" {e['unit']}" if e["unit"] else "") + f" = {want:g}"
                + (f" {e['capture_unit']}" if e["capture_unit"] else "") + f", the capture prints {got:g}: they differ"]
    return []


def _occurrences(hay, needle, where):
    """Where `needle` stands in `hay` as a whole SAY sentence (after the start or a sentence end) or a whole deck cell (between spaces)."""
    out = []
    for m in re.finditer(re.escape(needle), hay):
        s, f = m.span()
        lead = s == 0 or (hay[s - 1].isspace() and (where == "deck" or not hay[:s].strip()
                                                   or re.search(r"[.!?][\"”’')\]]*$", hay[:s].rstrip())))
        if lead and (f == len(hay) or hay[f].isspace()):
            out.append((s, f))
    return out


def load_allow(path=None):
    """(table, md5, problems) of the ALLOW table — `_builders/dur9_allow.py` beside this file unless `path` is given. The file is DATA: it is
    parsed with ast and never executed, and it may hold exactly one statement, `ALLOW = {…}` (a literal). A missing or malformed table is a
    problem, so the gate fails rather than read it as 'nothing allowed by accident'."""
    path = path or os.path.join(os.path.dirname(os.path.abspath(__file__)), "dur9_allow.py")
    try:
        raw = open(path, "rb").read()
    except OSError as x:
        return {}, None, [f"the allowance table {path} cannot be read ({x.__class__.__name__})"]
    md = hashlib.md5(raw).hexdigest()
    try:
        tree = ast.parse(raw.decode("utf-8"), path)
    except (SyntaxError, ValueError, UnicodeDecodeError) as x:
        return {}, md, [f"the allowance table does not parse ({x.__class__.__name__})"]
    body = [n for n in tree.body if not (isinstance(n, ast.Expr) and isinstance(n.value, ast.Constant) and isinstance(n.value.value, str))]
    if (len(body) != 1 or not isinstance(body[0], ast.Assign) or len(body[0].targets) != 1
            or not isinstance(body[0].targets[0], ast.Name) or body[0].targets[0].id != "ALLOW"):
        return {}, md, ["the allowance table holds exactly one statement, `ALLOW = {…}`: data, never code"]
    try:
        table = ast.literal_eval(body[0].value)
    except (ValueError, TypeError, SyntaxError, MemoryError, RecursionError):
        return {}, md, ["ALLOW is not a literal (data only)"]
    if not isinstance(table, dict) or not all(isinstance(k, str) and re.fullmatch(r"\d\d", k) and isinstance(v, (tuple, list))
                                              for k, v in table.items()):
        return {}, md, ["ALLOW maps a zero-padded unit ('04') to a tuple of entries"]
    return table, md, []


def judge(unit, spoken, prose, table, code_dir):
    """S9.9 for one unit: (spoken_rest, prose_rest, exempted, problems). Every entry of table[unit] is judged on the ORIGINAL texts first
    (BLUE ROUND 2, RED2 #15: masking one entry used to erase the sentence end the next, adjacent entry needed); each one that holds then has
    its ONE occurrence replaced by ' ¶ ' (so dur9 judges the rest unchanged, and no words join across the gap). `exempted` lists
    (where, text, its dur9 hits, kind, capture). An entry that does not hold is a problem and exempts nothing. Never raises. The builders
    and check_unit9.py call this same function with the same texts."""
    texts = {"say": spoken, "deck": prose}
    exempted, problems, cuts = [], [], {"say": [], "deck": []}
    entries = table.get(unit, ()) if isinstance(table, dict) else ()
    for i, e in enumerate(entries if isinstance(entries, (tuple, list)) else (), 1):
        p = entry_problems(e)
        label = f"allowance {unit}#{i}" + (f" ({e.get('kind')}, {e.get('where')})" if isinstance(e, dict) and not p else "")
        if not p:
            try:
                p = capture_problems(e, code_dir)
            except Exception as x:                       # an unreadable capture is a problem, never a traceback
                p = [f"its capture could not be read ({type(x).__name__})"]
        spans = []
        if not p:
            spans = _occurrences(texts[e["where"]], e["text"], e["where"])
            if len(spans) != 1:
                p = [f"its text occurs {len(spans)} times as a whole {'sentence of the SAY lines' if e['where'] == 'say' else 'deck cell'} "
                     "— an entry is exactly one sentence of its own unit" + (" (a dead entry)" if not spans else "")]
        if not p and any(a < spans[0][1] and spans[0][0] < b for a, b in cuts[e["where"]]):
            p = ["its text overlaps another entry's"]
        if p:
            problems += [f"{label}: {x}" for x in p]
            continue
        cuts[e["where"]].append(spans[0])
        exempted.append((e["where"], e["text"], words(e["text"]), e["kind"], e["capture"]))
    rest = {}
    for w, t in texts.items():
        for a, b in sorted(cuts[w], reverse=True):
            t = t[:a] + " ¶ " + t[b:]
        rest[w] = t
    return rest["say"], rest["deck"], exempted, problems


def gate(unit, spoken, prose, code_dir, chapters="", table=None):
    """A builder's call (s9NN.py): the same judge() check_unit9.py runs, printed the same way. Raises AssertionError on any problem or any
    remaining dur9 word; returns the exempted list. `spoken` = the SAY beats joined with spaces, `prose` = check_unit9.deck_prose() of the
    deck, `chapters` = the slide titles joined (they become the YouTube chapters)."""
    if table is None:
        table, md, tp = load_allow()
        assert not tp, ("dur9 allowance table", tp)
        print(f"  · allowance table (S9.9) md5 {md}: {len(table.get(unit, ()))} entr{'y' if len(table.get(unit, ())) == 1 else 'ies'} for unit {unit}")
    sp, pr, ex, probs = judge(unit, spoken, prose, table, code_dir)
    for w, t, h, k, c in ex:
        print(f"  · exempted (S9.9, {k}, {c}): [{w}] {t!r} — {h}")
    found = {k: v for k, v in (("spoken", words(sp)), ("deck prose", words(pr)), ("chapter names", words(chapters))) if v}
    assert not probs and not found, ("dur9 (R.165, ⚑10, S9.9)", probs, found)
    return ex


# The allowance's own plants that need no file (the capture half is check_unit9.py --selftest's, end to end through main()):
assert number_value("thirty") == 30 and number_value("twenty-four") == 24 and number_value("one hundred and twenty") == 120
assert number_value("a") == 1 and number_value("1.5") == 1.5 and number_value("zero") == 0 and number_value("soon") is None
_E = {"where": "say", "text": "The answer's Retry-After header says thirty.", "kind": "Retry-After", "capture": ".r-limit.out",
      "line": r"^< Retry-After: (?P<v>\d+)\r?$", "says": "thirty", "unit": None, "capture_unit": None}
assert entry_problems(_E) == [], entry_problems(_E)
for _k, _v, _why in (("text", "The answer's Retry-After header says thirty, and it took a second.", "latency"),
                     ("text", "The answer's header says thirty.", "names what is configured"),
                     ("text", "The answer's Retry-After header is set.", "dur9 does not fire"),
                     ("text", "The answer's Retry-After header says thirty, and the key lives a day.", "does not back"),
                     ("text", "the answer's Retry-After header says thirty.", "whole sentence"),
                     ("kind", "latency", "not one of"), ("capture", "limit.txt", "capture name"), ("line", "^< Retry-After: \\d+$", "(?P<v>"),
                     ("says", "soon", "neither digits"), ("unit", "day", "both None")):
    assert any(_why in _x for _x in entry_problems(dict(_E, **{_k: _v}))), ("allowance plant must be refused", _k, _v, entry_problems(dict(_E, **{_k: _v})))
assert entry_problems(dict(_E, text="The key is kept for a day.", kind="key lifetime", says="a", unit="day", capture_unit="h",
                           line=r"ttl=PT(?P<v>\d+)H")) == []
# BLUE ROUND 2 (RED2-C9-TOOLS #3, #2): only the value and the name attached to it are exempted; one sentence; no latency unit; a malformed
# entry is a problem, never a TypeError
for _txt, _why in (("The Retry-After header, sent two days later, says thirty.", "does not back"),
                   ("The Retry-After header waits a week. It then says thirty.", "ONE sentence"),
                   ("The Retry-After header, 12 ms after the request, says thirty.", "does not back"),
                   ("The Retry-After header arrived four hundred microseconds later and says thirty.", "latency"),
                   ("The Retry-After header, at the p99, says thirty.", "latency"),
                   ("The key is kept, as the run shows two hours and five minutes in, for a day.", "does not back")):
    _ee = dict(_E, text=_txt) if not _txt.startswith("The key") else dict(_E, text=_txt, kind="key lifetime", says="a", unit="day",
                                                                          capture_unit="h", line=r"ttl=PT(?P<v>\d+)H")
    assert any(_why in _x for _x in entry_problems(_ee)), ("allowance round-2 plant must be refused", _txt, entry_problems(_ee))
for _k, _v in (("kind", ["Retry-After"]), ("unit", ["day"]), ("says", 30), ("text", ["x"]), ("capture_unit", 5), ("line", None)):
    assert any("must be strings" in _x for _x in entry_problems(dict(_E, **{_k: _v}))), ("a malformed entry is a problem", _k, _v)
assert claim_regions(_E) == [(_E["text"].index("Retry-After"), _E["text"].index("thirty") + len("thirty"))]
assert entry_problems(dict(_E, text="The Retry-After header on that answer says thirty.")) == []   # the value alone exempted: the rest passes
assert _occurrences("One. The answer's Retry-After header says thirty. Two.", _E["text"], "say") != []
assert _occurrences("One, the answer's Retry-After header says thirty. Two.", "the answer's Retry-After header says thirty.", "say") == []

if __name__ == "__main__":
    print(f"dur9 self-test: OK (dur8's 11 must-match + 10 must-not-match carried; S9.18's {len(PLANTS)} plants match, its "
          f"{len(NEAR_MISSES)} near misses pass; LANE 7's {len(PLANTS_LANE7)} plants match, {len(NEAR_MISSES_LANE7)} near misses pass; "
          f"BLUE C9-TOOLS' {len(PLANTS_BLUE)} plants match, {len(NEAR_MISSES_BLUE)} near misses pass; BLUE ROUND 2's "
          f"{len(PLANTS_BLUE2)} plants match, {len(NEAR_MISSES_BLUE2)} near misses pass; every one of the "
          f"{len(_W) + len(_P) + len(_T)} alternatives exercised alone; the allowance's static plants hold)")
    _tb, _md, _tp = load_allow()
    print(f"dur9_allow.py: md5 {_md}, {sum(len(v) for v in _tb.values())} entr(y/ies) over units {sorted(_tb)}" + (f" — PROBLEMS {_tp}" if _tp else ""))
    print(f"dur9.py md5 {hashlib.md5(open(os.path.abspath(__file__), 'rb').read()).hexdigest()}")
