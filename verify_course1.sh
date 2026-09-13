#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# verify_course1.sh — Course 1 (Java Fundamentals), units 01-39 + capstone.
#
# Walks every unit folder, runs every command printed in that unit's README,
# and checks the result:
#   * normal files            must exit 0 and print the expected text
#   * "supposed to fail" files must exit non-zero and print the expected error
#   * "supposed to be wrong"   files must exit 0 and print the wrong-but-expected
#                              answer that the lesson is about
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

# step <ok|fail|wrong> <subdir> <expected text> <command>
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
