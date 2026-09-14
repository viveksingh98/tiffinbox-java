#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# verify_course1.sh — Course 1 (Java Fundamentals), units 01-46 + capstone.
#
# Walks every unit folder, runs every command printed in that unit's README,
# and checks the result:
#   * normal files            must exit 0 and print the expected text
#   * "supposed to fail" files must exit non-zero and print the expected error
#   * "supposed to be wrong"   files must exit 0 and print the wrong-but-expected
#                              answer that the lesson is about
#
# Section 9 (units 40-46) also ships an exercise per unit: the starter must
# compile and run unedited, and the worked solution must print the acceptance
# block from that unit's exercise/README.md byte for byte.
#
# Usage:   ./verify_course1.sh              # everything
#          ./verify_course1.sh unit05 unit26  # only those folders
#          TIMEOUT_SECS=60 ./verify_course1.sh
#
# Needs JDK 25 (java, javac, javap, jar) and, for units 34/35/37/38 and the
# capstone, Apache Maven 3.9.x. Maven units are skipped (not failed) if mvn is
# missing. Exit code is 0 only when every check passed.
# ---------------------------------------------------------------------------
set -u
cd "$(dirname "$0")" || exit 2

# JDK 25: honour an existing JAVA_HOME, else use the Homebrew location.
if [ -z "${JAVA_HOME:-}" ] && [ -x /opt/homebrew/opt/openjdk@25/bin/java ]; then
  JAVA_HOME=/opt/homebrew/opt/openjdk@25
fi
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  export JAVA_HOME
  export PATH="$JAVA_HOME/bin:$PATH"
fi
command -v java >/dev/null 2>&1 || { echo "no java on PATH — install JDK 25"; exit 2; }

TIMEOUT_SECS="${TIMEOUT_SECS:-180}"
ONLY="$*"
TMPOUT="$(mktemp -t course1out)"
trap 'rm -f "$TMPOUT"' EXIT

RED=""; GREEN=""; YELLOW=""; OFF=""
if [ -t 1 ]; then RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; OFF=$'\033[0m'; fi

TOTAL_CHECKS=0; FAILED_UNITS=""; SKIPPED_UNITS=""; PASSED=0; UNIT=""; UNIT_FAILS=0; UNIT_CHECKS=0; UNIT_SKIP=0

echo "java:  $(java -version 2>&1 | head -1)"
if command -v mvn >/dev/null 2>&1; then echo "maven: $(mvn -v 2>/dev/null | head -1)"; else echo "maven: ${YELLOW}not found — Maven units will be skipped${OFF}"; fi
echo

# Run a command with a wall-clock timeout (macOS has no coreutils `timeout`).
run_with_timeout() {
  local secs="$1" dir="$2" cmd="$3" pid waited rc
  ( cd "$dir" && eval "$cmd" ) >"$TMPOUT" 2>&1 &
  pid=$!
  waited=0
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$((secs * 10))" ]; then
      kill -9 "$pid" 2>/dev/null
      wait "$pid" 2>/dev/null
      echo "[timed out after ${secs}s]" >>"$TMPOUT"
      return 124
    fi
    sleep 0.1
    waited=$((waited + 1))
  done
  wait "$pid"; rc=$?
  return $rc
}

begin_unit() {
  UNIT="$1"; UNIT_FAILS=0; UNIT_CHECKS=0; UNIT_SKIP=0
}

skip_unit_if_no_mvn() {
  if ! command -v mvn >/dev/null 2>&1; then UNIT_SKIP=1; fi
}

pre() { [ -n "$ONLY" ] && ! printf '%s\n' $ONLY | grep -qx "$UNIT" && return 0
        [ "$UNIT_SKIP" = 1 ] && return 0
        ( cd "$UNIT" && eval "$1" ) >/dev/null 2>&1; return 0; }

# step <ok|fail|wrong|exact> <subdir> <expected text> <command>
#   ok / wrong / fail : the expected text must appear somewhere in the output
#   exact             : the output must BE the expected text, byte for byte
#                       (the acceptance blocks of the Section 9 exercises)
step() {
  local kind="$1" sub="$2" expect="$3" cmd="$4" rc out label
  if [ -n "$ONLY" ] && ! printf '%s\n' $ONLY | grep -qx "$UNIT"; then return 0; fi
  if [ "$UNIT_SKIP" = 1 ]; then return 0; fi
  UNIT_CHECKS=$((UNIT_CHECKS + 1)); TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  run_with_timeout "$TIMEOUT_SECS" "$UNIT/$sub" "$cmd"; rc=$?
  out="$(cat "$TMPOUT")"
  label="$UNIT/$sub: $cmd"
  if [ "$kind" = fail ]; then
    if [ "$rc" -eq 0 ]; then
      UNIT_FAILS=$((UNIT_FAILS + 1)); echo "  ${RED}x${OFF} $label — expected a FAILURE, but it exited 0"; return 0
    fi
    if [ "$rc" -eq 124 ]; then
      UNIT_FAILS=$((UNIT_FAILS + 1)); echo "  ${RED}x${OFF} $label — timed out"; return 0
    fi
  else
    if [ "$rc" -ne 0 ]; then
      UNIT_FAILS=$((UNIT_FAILS + 1)); echo "  ${RED}x${OFF} $label — exit $rc"; echo "$out" | tail -6 | sed 's/^/      /'; return 0
    fi
  fi
  if [ "$kind" = exact ]; then
    if [ "$out" != "$expect" ]; then
      UNIT_FAILS=$((UNIT_FAILS + 1))
      echo "  ${RED}x${OFF} $label — output is not the acceptance block, byte for byte"
      diff <(printf '%s\n' "$expect") <(printf '%s\n' "$out") | sed 's/^/      /'
    fi
    return 0
  fi
  case "$out" in
    *"$expect"*) : ;;
    *) UNIT_FAILS=$((UNIT_FAILS + 1))
       echo "  ${RED}x${OFF} $label — expected text not found: $expect"
       echo "$out" | tail -6 | sed 's/^/      /' ;;
  esac
}

end_unit() {
  if [ -n "$ONLY" ] && ! printf '%s\n' $ONLY | grep -qx "$UNIT"; then return 0; fi
  if [ "$UNIT_SKIP" = 1 ]; then
    SKIPPED_UNITS="$SKIPPED_UNITS $UNIT"; printf '%-10s %sSKIP%s (needs Maven)\n' "$UNIT" "$YELLOW" "$OFF"; return 0
  fi
  if [ "$UNIT_FAILS" -eq 0 ]; then
    PASSED=$((PASSED + 1)); printf '%-10s %sPASS%s (%d checks)\n' "$UNIT" "$GREEN" "$OFF" "$UNIT_CHECKS"
  else
    FAILED_UNITS="$FAILED_UNITS $UNIT"; printf '%-10s %sFAIL%s (%d of %d checks failed)\n' "$UNIT" "$RED" "$OFF" "$UNIT_FAILS" "$UNIT_CHECKS"
  fi
}

post() { [ -n "$ONLY" ] && ! printf '%s\n' $ONLY | grep -qx "$UNIT" && return 0
         ( cd "$UNIT" && eval "$1" ) >/dev/null 2>&1; return 0; }


# --- unit01: Why Java in 2026 (and How This Course Works)
begin_unit unit01
step ok . 'Hello, TiffinBox!' 'java Hello.java'
end_unit

# --- unit02: Install JDK 25 and IntelliJ (Mac + Windows)
begin_unit unit02
step ok . version 'java -version'
step ok . 'Hello, TiffinBox!' 'java Main.java'
end_unit

# --- unit03: Your First Program: Hello, TiffinBox
begin_unit unit03
step ok . 'Hello, TiffinBox!' 'java Hello.java'
step ok classic 'Hello, TiffinBox!' 'java Hello.java'
step fail broken ''"'"';'"'"' expected' 'java Hello.java'
end_unit

# --- unit04: How Java Actually Runs: Source, Bytecode, JVM
begin_unit unit04
step ok . 'Hello, TiffinBox!' 'java Hello.java'
step ok . Hello.class 'javac Hello.java && ls Hello.class'
step ok . 'Hello, TiffinBox!' 'java Hello'
step ok . invokevirtual 'javap -c Hello'
post 'rm -f Hello.class'
end_unit

# --- unit05: Variables and Types: Where Data Lives
begin_unit unit05
step ok . 'Ravi eats 2 meals, pays 240.0' 'java Customer.java'
step fail . 'incompatible types: String cannot be converted to int' 'java BreakIt.java'
end_unit

# --- unit06: Operators and Expressions: Ravi's Monthly Bill
begin_unit unit06
step ok . 'Monthly bill: 7200' 'java Bill.java'
step ok . 'Bill: 7000, meals: 3' 'java Shortcuts.java'
step ok . 'Skipped: 23.3%' 'java Skipped.java'
end_unit

# --- unit07: Strings: Text Done Right
begin_unit unit07
step ok . 'COTTAGE CHEESE CURRY' 'java Menu.java'
step ok . 'TiffinBox - Monday' 'java MenuCard.java'
step ok . false 'java Compare.java'
end_unit

# --- unit08: Making Decisions: if, else, switch
begin_unit unit08
step ok . 'vegan meal: 130' 'java Pricing.java'
step ok . 'Vegan: no dairy, no eggs' 'java Pricing2.java'
step ok . priced 'java Label.java'
step fail . 'does not cover all possible input values' 'java BreakSwitch.java'
end_unit

# --- unit09: Loops: Doing It 30 Times
begin_unit unit09
step ok . '30-day bill: 7200' 'java MonthLoop.java'
step ok . '8 days of tiffin, 80 left' 'java Wallet.java'
step ok . 'Budget alert on day 24' 'java SkipSundays.java'
step ok . 'Mon: tiffin delivered' 'java WeekPreview.java'
step fail . 'cannot find symbol' 'java BreakScope.java'
end_unit

# --- unit10: Methods: Name a Piece of Work
begin_unit unit10
step ok . 'Ravi owes 7200 this month' 'java Billing.java'
step fail . 'missing return statement' 'java BreakReturn.java'
end_unit

# --- unit11: Arrays: Seven Days of Menus
begin_unit unit11
step ok . '- lentil rice' 'java WeekMenu.java'
step ok . 'Meals this week: 330' 'java Orders.java'
step fail . ArrayIndexOutOfBoundsException 'java BreakIndex.java'
end_unit

# --- unit12: Classes and Objects: Meet Customer
begin_unit unit12
step ok . 'Ravi eats 2 meals a day' 'java Customer.java'
step fail . 'might not have been initialized' 'java BreakNoNew.java'
end_unit

# --- unit13: Constructors and this
begin_unit unit13
step ok . 'Ravi: 7200' 'java Constructors.java'
step wrong . null 'java Shadow.java'
step fail . 'cannot be applied to given types' 'java BreakNoArgs.java'
end_unit

# --- unit14: Encapsulation: Private Fields, Public Doors
begin_unit unit14
step ok . 'Rejected: -5 meals a day' 'java Encapsulation.java'
step fail . 'has private access' 'java BreakPrivate.java'
step fail breakfinal 'might not have been initialized' 'java BreakFinal.java'
end_unit

# --- unit15: Inheritance: Meal, VegMeal, NonVegMeal
begin_unit unit15
step ok . 'vegetable stew - 130 (no dairy, no eggs)' 'java Meals.java'
step wrong . 'vegetable stew - 120' 'java SilentBug.java'
step fail . 'does not override or implement a method from a supertype' 'java BreakOverride.java'
end_unit

# --- unit16: Polymorphism: One Call, Many Behaviours
begin_unit unit16
step ok . 'Total: 400' 'java Polymorphism.java'
step fail . 'cannot find symbol' 'java BreakUpcast.java'
step ok . 'Vegan: no dairy, no eggs' 'java FixUpcast.java'
end_unit

# --- unit17: Abstract Classes and Interfaces
begin_unit unit17
step ok . 'vegetable stew - 130' 'java AbstractMeal.java'
step ok . 'Sunil earns 8800' 'java Payable.java'
step fail . 'is abstract; cannot be instantiated' 'java BreakAbstract.java'
step fail . 'does not override abstract method' 'java BreakInterface.java'
end_unit

# --- unit18: Records, Enums and Sealed Types
begin_unit unit18
step ok . 'Order[customer=Ravi, type=VEG, quantity=2]' 'java Orders.java'
step ok . 'UPI to ravi@okbank' 'java Payments.java'
step fail . 'cannot assign a value to final variable' 'java BreakRecord.java'
step fail . 'does not cover all possible input values' 'java BreakSealed.java'
end_unit

# --- unit19: ArrayList: A List That Grows
begin_unit unit19
step ok . '3 customers, first: Ravi' 'java Customers.java'
step ok . '3 orders, today'"'"'s takings: 520' 'java Orders.java'
step ok . '[Meera, Sunil]' 'java FixLoop.java'
step fail . UnsupportedOperationException 'java BreakFixed.java'
step fail . ConcurrentModificationException 'java BreakLoop.java'
end_unit

# --- unit20: HashMap and HashSet: Look Things Up Fast
begin_unit unit20
step ok . '{Meera=4800, Ravi=7200, Sunil=3600}' 'java Dues.java'
step ok . '2 unique: [98200 22222, 98200 11111]' 'java Phones.java'
step fail . NullPointerException 'java BreakNull.java'
end_unit

# --- unit21: Generics: Why List<String> Not Just List
begin_unit unit21
step ok . 7200 'java Generics.java'
step fail . 'incompatible types: Object cannot be converted to String' 'java BreakRaw.java'
step fail . 'no suitable method found for add(int)' 'java BreakTyped.java'
step fail . 'inference variable T has incompatible bounds' 'java BreakMax.java'
step fail . ClassCastException 'java RawCrash.java'
end_unit

# --- unit22: Sorting and Comparators
begin_unit unit22
step ok . '[Meera, Ravi, Sunil]' 'java Sorting.java'
step ok . 'Meera 1 meals, bill 4500' 'java ComparableDemo.java'
step ok . 'Sunil 3600 | Meera 4500 | Ravi 7200 |' 'java Comparators.java'
step fail . 'no suitable method found for sort' 'java BreakSort.java'
step fail . 'incompatible bounds' 'java BreakNatural.java'
end_unit

# --- unit23: equals, hashCode and toString
begin_unit unit23
step ok . false 'java Identity.java'
step ok . 'Ravi (2 meals/day)' 'java ToStringDemo.java'
step wrong . 'contains Ravi: false' 'java BreakSet.java'
step ok . 'contains Ravi: true' 'java FixSet.java'
step ok . 'Customer[name=Ravi, mealsPerDay=2]' 'java RecordSet.java'
step fail . 'does not override or implement a method from a supertype' 'java BreakEqualsSig.java'
end_unit

# --- unit24: Exceptions: When Things Go Wrong
begin_unit unit24
step fail . 'ArithmeticException: / by zero' 'java Trace.java'
step ok . 'Program continues' 'java Catch.java'
step ok . 'Skipped: unknown meal type: vge' 'java Throw.java'
step ok . '1 customers on file' 'java FixChecked.java'
step fail . 'unreported exception IOException' 'java BreakChecked.java'
post 'rm -f customers.csv'
end_unit

# --- unit25: Custom Exceptions and Clean Error Handling
begin_unit unit25
step ok . 'Rejected: meals a day must be 1 to 3, got -5' 'java CustomException.java'
step ok . 'log closed' 'java Resource.java'
step wrong . 'Bill for Ravi: 7200' 'java Swallow.java'
step fail . 'Caused by: java.lang.ArithmeticException' 'java Cause.java'
end_unit

# --- unit26: Files: Read and Write with java.nio
begin_unit unit26
step ok . 'Saved customers.csv: true, 34 bytes' 'java SaveCustomers.java'
step ok . '2 customers on file' 'java ReadCustomers.java'
step ok . '3 customers on file' 'java AppendCustomers.java'
step fail . NoSuchFileException 'java BreakFile.java'
step ok . 'No file yet, starting empty: customer.csv' 'java FixFile.java'
post 'rm -f customers.csv'
end_unit

# --- unit27: Parsing Data: CSV to Objects
begin_unit unit27
step ok . 'Customer[name=Ravi, mealsPerDay=2, pricePerMeal=120, isVeg=true]' 'java ParseOne.java'
step ok . '3 customers, 15300 a month' 'java LoadCustomers.java'
step ok . 'Saved 3' 'java RoundTrip.java'
step fail . NumberFormatException 'java BreakParse.java'
step ok . 'Skipped line 4' 'java FixParse.java'
post 'rm -f customers.csv'
end_unit

# --- unit28: Lambdas and Functional Interfaces
begin_unit unit28
step ok . '2 veg customers' 'java Lambdas.java'
step ok . true 'java OldWay.java'
step ok . 'Revenue: 15300' 'java FixCapture.java'
step fail . 'must be final or effectively final' 'java BreakCapture.java'
end_unit

# --- unit29: Streams: Reports in One Line
begin_unit unit29
step ok . 'Monthly revenue: 15300' 'java Reports.java'
step ok . 'Takings: 640' 'java Takings.java'
step ok . 'pipeline built, nothing ran yet' 'java Lazy.java'
step fail . 'stream has already been operated upon or closed' 'java BreakStream.java'
end_unit

# --- unit30: Optional: The End of null Checks
begin_unit unit30
step ok . Optional.empty 'java Finder.java'
step ok . 'Customer[name=Guest, mealsPerDay=1, pricePerMeal=120, isVeg=true]' 'java WhenAbsent.java'
step fail . NullPointerException 'java NullFinder.java'
step fail . 'NoSuchElementException: No value present' 'java BreakOptional.java'
end_unit

# --- unit31: Pattern Matching: instanceof and switch
begin_unit unit31
step ok . 'Meera paid for 1 NON_VEG by UPI (meera@okbank)' 'java Patterns.java'
step fail . NullPointerException 'java NullSwitch.java'
step fail . 'does not cover all possible input values' 'java BreakGuard.java'
step fail . 'dominated by a preceding case label' 'java BreakDominated.java'
step fail . 'cannot find symbol' 'java OrScope.java'
end_unit

# --- unit32: Dates and Times with java.time
begin_unit unit32
step ok . 'Ravi'"'"'s bill: 5520' 'java Pause.java'
step ok . 'Pause from 14/09/2026' 'java Formats.java'
step fail . DateTimeParseException 'java BreakDate.java'
step fail . 'Invalid date '"'"'FEBRUARY 30'"'"'' 'java BreakInvalid.java'
end_unit

# --- unit33: Packages, Imports and Project Structure
begin_unit unit33
pre 'rm -rf out'
step ok . Main.class 'javac -d out src/main/java/com/tiffinbox/*.java && ls out/com/tiffinbox'
step ok . 'Ravi pays 7200' 'java -cp out com.tiffinbox.Main'
step ok . '[Ravi, Meera, Sunil]' 'java -cp out com.tiffinbox.ModuleImports'
step fail . 'wrong name: com/tiffinbox/Main' 'cd out/com/tiffinbox && java Main'
post 'rm -rf out'
end_unit

# --- unit34: Maven in 15 Minutes
begin_unit unit34
skip_unit_if_no_mvn
step ok . tiffinbox-1.0.jar 'mvn -q package && ls target'
step ok . 'Ravi pays 7200' 'java -jar target/tiffinbox-1.0.jar'
step ok . 'Ravi pays 7200' 'java -cp target/classes com.tiffinbox.Main'
step ok . com/tiffinbox/Main.class 'jar tf target/tiffinbox-1.0.jar'
end_unit

# --- unit35: Testing with JUnit 5
begin_unit unit35
skip_unit_if_no_mvn
step ok . 'Tests run: 3, Failures: 0' 'mvn -B test'
step ok . tiffinbox-1.0.jar 'mvn -q package && ls target'
end_unit

# --- unit36: Debugging in IntelliJ
begin_unit unit36
pre 'rm -rf out'
step ok . 'September total: 7200' 'javac -d out MonthReport.java Billing.java && java -cp out com.tiffinbox.MonthReport'
step wrong . 'September total: 6960' 'javac -g -d out/buggy buggy/MonthReport.java Billing.java && java -cp out/buggy com.tiffinbox.MonthReport'
post 'rm -rf out'
end_unit

# --- unit37: TiffinBox Console App: The Design
begin_unit unit37
skip_unit_if_no_mvn
step ok . 'Choose (1-5)' 'cd ../capstone && mvn -q package && printf '"'"'5\n'"'"' | java -jar target/tiffinbox-1.0.jar'
end_unit

# --- unit38: TiffinBox: Build It
begin_unit unit38
skip_unit_if_no_mvn
step ok . 'Tests run: 11, Failures: 0' 'cd ../capstone && mvn -B test'
step ok . 'Total revenue: 15300' 'cd ../capstone && mvn -q package && printf '"'"'1\n3\n5\n'"'"' | java -jar target/tiffinbox-1.0.jar'
end_unit

# --- unit39: What's Next: Spring Boot, AI Agents and Your Java Path
begin_unit unit39
step ok . 'Hello, TiffinBox!' 'java Hello.java'
end_unit

# --- capstone: TiffinBox Console App (Capstone)
begin_unit capstone
skip_unit_if_no_mvn
step ok . 'Tests run: 11, Failures: 0' 'mvn -B test'
step ok . tiffinbox-1.0.jar 'mvn -q package && ls target/tiffinbox-1.0.jar'
step ok . 'Total revenue: 15300' 'printf '"'"'1\n3\n5\n'"'"' | java -jar target/tiffinbox-1.0.jar'
step ok . 'paused 7 days' 'printf '"'"'2\nPriya\n2\ny\n\n4\nRavi\n14/09/2026\n20/09/2026\n3\n5\n'"'"' | java -jar target/tiffinbox-1.0.jar'
post 'git checkout -- customers.csv 2>/dev/null || true'
end_unit


# ===========================================================================
# Section 9 — units 40-46. Every unit here also ships exercise/: a starter that
# must compile and run unedited, and a worked solution whose output must match
# the acceptance block of that unit's exercise/README.md byte for byte.
# ===========================================================================

# --- unit40: Recursion, Varargs and Two-Dimensional Arrays
begin_unit unit40
step ok    . 'Family lunch costs 270' 'java Combo.java'
step ok    . '<- 270' 'java ComboTrace.java'
step ok    . 'bean curry in the lunch?  true' 'java Contains.java'
step fail  . 'java.lang.StackOverflowError' 'java BreakBaseCase.java'
step ok    . 1019 'java BreakBaseCase.java 2>&1 | grep -c "BreakBaseCase.daysLeft(BreakBaseCase.java:5)"'
step ok    . 'Recursion: 30' 'java DaysLeft.java'
step fail  . 'java.lang.StackOverflowError' 'java NoTailCalls.java'
step ok    . 1019 'java NoTailCalls.java 2>&1 | grep -c "NoTailCalls.countDown(NoTailCalls.java:"'
step ok    . '5 bills [7200, 4500, 3600, 7200, 5520] -> 28020' 'java Varargs.java'
step fail  . 'varargs parameter must be the last parameter' 'java BreakVarargs.java'
step ok    . 'Week total: veg 288, non-veg 91' 'java WeekGrid.java'
step ok    . 'deepToString: [[40, 12], [38, 10], [42, 14], [41, 9], [45, 18], [52, 22], [30, 6]]' 'java FlatVsDeep.java'
step ok    . 'toString    : [[I@' 'java FlatVsDeepWarm.java'
step ok    . 'First busy slot: Wed' 'java Labels.java'
step ok    . 'binarySearch(sorted, 50)  : 4' 'java ArraysToolkit.java'
step ok    exercise 'Busiest day     : ?' 'java PartyBoxStarter.java'
step exact exercise 'Meals in the box: 3
Nesting depth   : 3
Cheapest of 120, 60, 90: 60
Cheapest of nothing    : 0
Busiest day     : Sat (74 meals)
Grid            : [[40, 12], [38, 10], [42, 14], [41, 9], [45, 18], [52, 22], [30, 6]]' 'java PartyBox.java'
end_unit

# --- unit41: Numbers You Can Trust: Ranges, Overflow, Math and Random
begin_unit unit41
step ok    . 'int  total paise: -1796567296' 'java Overflow.java'
step ok    . 'long      64    -9223372036854775808  9223372036854775807' 'java Ranges.java'
step fail  . 'integer number too large' 'java BreakLiteral.java'
step ok    . '0.1 + 0.2         = 0.30000000000000004' 'java Doubles.java'
step ok    . 'Math.rint(-2.5)  = -2.0' 'java Rounding.java'
step ok    . 'multiplyExact throws  : integer overflow' 'java MathTools.java'
step ok    . 'Dice: 3' 'java SeededRandom.java'
step ok    . 'Dice roll:' 'java Unseeded.java'
step ok    exercise 'Yearly paise (int would break): 0' 'java TillStarter.java'
step exact exercise 'Yearly paise (int would break): 29980800000
int would have given         : -83971072
4.35 rupees in paise, wrong  : 434
4.35 rupees in paise, right  : 435
Skipped, raw                 : 23.333333333333332
Skipped, for Asha            : 23.3%
Skipped, rounded to a whole  : 23
Meal of day 1            : lentil rice
Meal of day 2            : cottage cheese curry
Meal of day 3            : combo plate' 'java Till.java'
end_unit

# --- unit42: Text, Properly: char, the Methods You'll Type Daily, and printf
begin_unit unit42
step ok    . 'Digits found: 9 of 10' 'java Chars.java'
step ok    . 'strip [Ravi] length 4' 'java TextToolkit.java'
step ok    . 'TOTAL                   22500' 'java -Duser.language=en -Duser.country=US Printf.java'
step ok    . 'Ravi owes 7200 rupees (32.0% of revenue)' 'java -Duser.language=en -Duser.country=US Conversions.java'
step ok    . 'Ravi owes 7200 rupees (32,0% of revenue)' 'java -Duser.language=de -Duser.country=DE Conversions.java'
step fail  . 'IllegalFormatConversionException: d != java.lang.Double' 'java BreakFormat.java'
step fail  . 'StringIndexOutOfBoundsException: Index 20 out of bounds for length 5' 'java BreakCharAt.java'
step ok    . 'codePointCount(): 7' 'java Emoji.java'
step ok    . '%n bytes: 11 [82, 97, 118, 105, 13, 10, 77, 101, 101, 114, 97]' 'java -Dline.separator=$'"'"'\r\n'"'"' Emoji.java'
step ok    exercise '?        9876543210     false  0' 'java SignUpFormStarter.java'
step exact exercise 'NAME     PHONE          OK     VOWELS
--------------------------------------
Meera    9876543210     true   3
Ravi     98765 43210    false  2
Guest    98765x4321     false  2
Priya    0123456789     true   2
All names: Meera, Ravi, Guest, Priya' 'java SignUpForm.java'
end_unit

# --- unit43: Talking to the User: Scanner, args, and a Program That Answers Back
begin_unit unit43
step ok    . 'Customer name: Meals per day: Welcome Priya - 2 meals a day, 7200 a month.' 'printf '"'"'Priya\n2\n'"'"' | java SignUp.java'
step wrong . 'Welcome [] - 2 meals a day.' 'printf '"'"'2\nPriya\n'"'"' | java BreakScanner.java'
step ok    . 'Welcome [Priya] - 2 meals a day.' 'printf '"'"'2\nPriya\n'"'"' | java FixScanner.java'
step ok    . 'nextBoolean() left: [true] rest of that line: []' 'printf '"'"'VEG\n2.5\ntrue\n'"'"' | java NextVariants.java'
step fail  . 'NoSuchElementException: No line found' 'printf '"'"''"'"' | java BreakClosed.java'
step ok    . '(no input - closing TiffinBox)' 'printf '"'"''"'"' | java Guard.java'
step ok    . 'Customer name: Welcome Priya' 'printf '"'"'Priya\n'"'"' | java Guard.java'
step ok    . 'hasNextLine now       : false' 'printf '"'"'\n'"'"' | java Blank.java'
step ok    . 'Customer name: Meals per day: Welcome Priya - 2 meals a day, 7200 a month.' 'printf '"'"'Priya\n2\n'"'"' | java Readln.java'
step fail  . 'NumberFormatException: Cannot parse null string' 'printf '"'"''"'"' | java Readln.java'
step ok    . 'name == null ? true' 'printf '"'"''"'"' | java ReadlnNull.java'
step ok    . 'public static java.lang.String readln(java.lang.String);' 'javap java.lang.IO'
step ok    . 'Ravi owes 7200 this month.' 'java Bill.java Ravi 2 120'
step fail  . 'NumberFormatException: For input string: "two"' 'java Bill.java Ravi two 120'
step ok    . 'Usage: java Bill.java <name> <mealsPerDay> <pricePerMeal>' 'java Bill.java'
step fail  . 'ArrayIndexOutOfBoundsException: Index 0 out of bounds for length 0' 'java BreakArgs.java'
step fail  . 'symbol:   class Scanner' 'java Classic.java'
step ok    . 'Welcome Priya' 'printf '"'"'Priya\n'"'"' | java ClassicFixed.java'
step ok    exercise 'Usage: java SignUpStarter.java <name> <mealsPerDay> <pricePerMeal>' 'java SignUpStarter.java Priya 2 120'
step ok    exercise 'Usage: java SignUpStarter.java <name> <mealsPerDay> <pricePerMeal>' 'printf '"'"'Priya\n2\n120\n'"'"' | java SignUpStarter.java'
step exact exercise 'Welcome Priya - 2 meals a day, 7200 a month.' 'java SignUp.java Priya 2 120'
step exact exercise 'Customer name: Meals per day (1-3): Price per meal: Welcome Priya - 2 meals a day, 7200 a month.' 'printf '"'"'Priya\n2\n120\n'"'"' | java SignUp.java'
step exact exercise 'Customer name: (input closed - nothing saved)' 'printf '"'"''"'"' | java SignUp.java'
step exact exercise 'Error: not a number - For input string: "two"' 'java SignUp.java Priya two 120'
step exact exercise 'Error: meals a day must be 1 to 3, got 9' 'java SignUp.java Priya 9 120'
step exact exercise 'Usage: java SignUp.java <name> <mealsPerDay> <pricePerMeal>' 'java SignUp.java Priya'
end_unit

# --- unit44: Comments, Javadoc, and How to Read the Java Docs
# javadoc runs OFFLINE here: there is no -link flag anywhere, so nothing reaches
# the network. Every docs/ tree it writes is removed again by the post below.
begin_unit unit44
pre 'rm -rf docs brokendocs slipdocs compact/docs compact/out exercise/docs exercise/out exercise/starter/docs exercise/starter/out'
step ok    . 'Ravi owes 7200' 'java Bill.java'
step ok    . 'Generating docs/com/tiffinbox/Customer.html...' 'rm -rf docs && javadoc -d docs src/main/java/com/tiffinbox/Customer.java'
step ok    . 61 'find docs -type f | wc -l'
step ok    . 'warning: no @param for customer' 'rm -rf brokendocs && javadoc -d brokendocs broken/com/tiffinbox/Order.java'
step fail  . 'error: @param name not found' 'rm -rf slipdocs && javadoc -d slipdocs broken/com/tiffinbox/Slip.java'
step fail  . 'StringIndexOutOfBoundsException: Range [14, 8) out of bounds for length 20' 'java Substring.java'
step ok    . 'caught as IndexOutOfBoundsException: java.lang.StringIndexOutOfBoundsException' 'java CatchParent.java'
step ok    . 'extends java.lang.IndexOutOfBoundsException' 'javap java.lang.StringIndexOutOfBoundsException'
step ok    deprecated 'has been deprecated and marked for removal' 'java MenuApp.java'
step ok    deprecated 'Menu: lentil rice, bean curry' 'java SameFile.java'
step ok    compact 3600 'java Quick.java'
step ok    compact 'Generating docs/Quick.Billing.html...' 'rm -rf docs && javadoc -d docs Quick.java'
step ok    compact '<title>Unnamed Package</title>' 'grep -o "<title>[^<]*</title>" docs/package-summary.html'
step ok    compact 'public class Quick$Billing {' 'rm -rf out && javac -d out Quick.java && javap -p -cp out '"'"'Quick$Billing'"'"''
step ok    exercise/starter 'Math.abs(Integer.MIN_VALUE): 0' 'rm -rf out && javac -d out src/com/tiffinbox/Pause.java && java -cp out PauseDemo.java'
step ok    exercise/starter '5 warnings' 'rm -rf docs && javadoc -d docs src/com/tiffinbox/Pause.java'
step exact exercise 'Ravi paused 7 days (14 to 20)
Days: 7
Math.abs(Integer.MIN_VALUE): -2147483648
Caught, exactly as the Javadoc promised: pause ends before it starts: 20 to 14' 'rm -rf out && javac -d out src/com/tiffinbox/Pause.java && java -cp out PauseDemo.java'
step ok    exercise 'zero warnings' 'rm -rf docs && javadoc -d docs src/com/tiffinbox/Pause.java 2>&1 | grep -q "warning" || echo "zero warnings"'
step ok    exercise 61 'find docs -type f | wc -l'
post 'rm -rf docs brokendocs slipdocs compact/docs compact/out exercise/docs exercise/out exercise/starter/docs exercise/starter/out'
end_unit

# --- unit45: The Keywords We Skipped: protected, final, static Interface Methods, Nested Classes
begin_unit unit45
pre 'rm -rf out packages/out break-package-private/out'
step ok    packages 'VeganMeal 130' 'javac -d out src/com/tiffinbox/menu/Meal.java src/com/tiffinbox/special/VeganMeal.java src/com/tiffinbox/app/Main.java && java -cp out com.tiffinbox.app.Main'
step fail  packages 'basePrice has protected access in Meal' 'javac -d out src/com/tiffinbox/menu/Meal.java src/com/tiffinbox/special/VeganMeal.java src/com/tiffinbox/special/Peek.java'
step fail  packages 'packedToday is not public in Meal; cannot be accessed from outside package' 'javac -d out src/com/tiffinbox/menu/Meal.java src/com/tiffinbox/app/Stock.java'
step fail  break-package-private 'basePrice is not public in Meal; cannot be accessed from outside package' 'javac -d out src/com/tiffinbox/menu/Meal.java src/com/tiffinbox/special/VeganMeal.java'
step ok    . 'deliveryFee() is final: true' 'java FinalProof.java'
step fail  . 'cannot inherit from final String' 'java BreakFinalClass.java'
step fail  . 'overridden method is final' 'java BreakFinalMethod.java'
step ok    . 'public final class java.lang.IO' 'javap java.lang.IO'
step ok    . 'Payable.of made a: Interfaces$Payable$1' 'java Interfaces.java'
step ok    . 'Receipt is tied to one    : Customer$Receipt' 'javac -d out Customer.java && java -cp out Customer'
step ok    . 'public Customer$Builder mealsPerDay(int);' 'javap -p -cp out '"'"'Customer$Builder'"'"''
step ok    . 'final Customer this$0;' 'javap -p -cp out '"'"'Customer$Receipt'"'"''
step fail  . 'an enclosing instance that contains Customer.Receipt is required' 'java -cp out BreakInner.java'
step ok    . 'Marked name    : ImplicitNesting$Marked' 'java ImplicitNesting.java'
step ok    . 'ImplicitNesting$Plain(ImplicitNesting);' 'javac -d out ImplicitNesting.java && javap -p -cp out '"'"'ImplicitNesting$Plain'"'"''
step ok    . 'ImplicitNesting$Marked();' 'javap -p -cp out '"'"'ImplicitNesting$Marked'"'"''
step ok    . 'class name: Anon$1' 'java Anon.java'
step ok    exercise 'Payable.of returns: KitchenStarter$Placeholder' 'java KitchenStarter.java'
step exact exercise 'DUE       Ravi       7200
REMINDER  Sunil      8800
Vegan meal price: 140 (delivery 20)
Priya | 7200 | paid by UPI
Guest | 0 | -
VeganMeal is final: true
Payable.of returns: Kitchen$Payable$1' 'java Kitchen.java'
post 'rm -rf out packages/out break-package-private/out'
end_unit

# --- unit46: You're On Your Own Now: Practice, Errors and Asking for Help
begin_unit unit46
step fail  . 'because "<local1>" is null' 'java Report.java'
step fail  . 'because "amount" is null' 'javac -g -d outg Report.java && java -cp outg Report'
step fail  . 'because "<local1>" is null' 'javac -d outn Report.java && java -cp outn Report'
step exact . 'Ravi owes 7200
Priya owes 0' 'java ReportFixed.java'
step fail  . 'symbol:   variable mealsperday' 'java E1CannotFindSymbol.java'
step fail  . 'symbol:   class HashMap' 'java BillsNoImport.java'
step fail  . 'incompatible types: String cannot be converted to int' 'java E2IncompatibleTypes.java'
step fail  . 'Index 7 out of bounds for length 7' 'java E3IndexOutOfBounds.java'
step fail  . 'at PauseReport$PauseBook.unpause(PauseReport.java:14)' 'java PauseReport.java'
step wrong . '[1, 2, 4, 5]' 'java Shrink.java'
step ok    . '[1, 3, 4, 5]' 'java ShrinkFixed.java'
step ok    . '[unpause] after remove list=[1, 2, 4, 5]' 'java Trace.java'
step fail  . 'symbol:   method capitalize()' 'java BreakHallucination.java'
step ok    . Meera 'java Capitalise.java'
# This unit's starter is the debugging exercise, so it is SUPPOSED to exit
# non-zero: assert the documented starting output, two lines then the NPE.
step fail  exercise 'Meera: 1
Sunil: 1
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because the return value of "java.util.HashMap.get(Object)" is null
	at DayReportStarter.main(DayReportStarter.java:21)' 'java DayReportStarter.java'
step fail  exercise 'at DayReportBroken.main(DayReportBroken.java:11)' 'java DayReportBroken.java'
step fail  exercise 'at Repro46.main(Repro46.java:3)' 'java Repro46.java'
step exact exercise 'Ravi: 2
Meera: 1
Sunil: 1
Priya: 0  (not subscribed today)
Meals to cook today: 4' 'java DayReport.java'
post 'rm -rf outg outn'
end_unit


echo
echo "-------------------------------------------------------------"
echo "units passed: $PASSED   checks run: $TOTAL_CHECKS"
[ -n "$SKIPPED_UNITS" ] && echo "skipped:     $SKIPPED_UNITS"
if [ -n "$FAILED_UNITS" ]; then
  echo "${RED}FAILED:     $FAILED_UNITS${OFF}"
  exit 1
fi
echo "${GREEN}ALL GREEN — every Course 1 example behaves as its README says.${OFF}"
exit 0
