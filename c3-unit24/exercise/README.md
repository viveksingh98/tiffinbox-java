# Exercise 24 — the rule that works for everyone except you

`gitignore.broken` is a two-line `.gitignore`. Copy this unit's project into a throwaway
repository with it in place, commit everything, and then **clone your own repository** and
look at what arrived:

```
mkdir -p /tmp/ex24 && cd /tmp/ex24
cp -R <c3-unit24>/src <c3-unit24>/pom.xml .
cp -R <c3-unit24>/wrapper/gradlew <c3-unit24>/wrapper/gradle .
cp <c3-unit24>/exercise/gitignore.broken .gitignore
git init -b main && git add -A && git commit -m "the project"
git status --porcelain          # says nothing. That is the problem.
git clone . ../ex24-clone
cd ../ex24-clone && ./gradlew --version
```

**Start state:** `git status` is clean, your copy builds, and the clone answers
`Error: Unable to access jarfile .../gradle-wrapper.jar`, exit **1**.

**End state:** `git ls-files '*.jar'` lists **exactly one** file —
`gradle/wrapper/gradle-wrapper.jar` — and `git ls-files '*target/*'` lists **none**. Change
`.gitignore` only; do not `git add -f` anything.

The answer is `solution/.gitignore`, and `../receipts.sh solution` runs both states and
stops if the untouched exercise already tracks the jar.
