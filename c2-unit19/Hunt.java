import java.util.*;

/// Measure — do not guess — the list size at which a broken comparator stops
/// being silent. 1000 random inputs per size, fixed seed so the sweep repeats.
record Rating(String customer, int stars) {}

static final Comparator<Rating> BROKEN = (a, b) -> a.stars() <= b.stars() ? -1 : 1;

static int throwsOutOf(int n, int trials, int distinctStars, long seed) {
    var rnd = new Random(seed);
    int hits = 0;
    for (int t = 0; t < trials; t++) {
        var list = new ArrayList<Rating>(n);
        for (int i = 0; i < n; i++) list.add(new Rating("c" + i, 1 + rnd.nextInt(distinctStars)));
        try { list.sort(BROKEN); } catch (IllegalArgumentException e) { hits++; }
    }
    return hits;
}

void main() {
    IO.println("n     1-5 stars   1-3 stars   (throws out of 1000 random inputs)");
    for (int n : new int[]{2, 8, 16, 24, 31, 32, 33, 40, 64, 100}) {
        IO.println(String.format("%-6d%-12d%d",
                n, throwsOutOf(n, 1000, 5, 19L), throwsOutOf(n, 1000, 3, 19L)));
    }
    int first = -1;
    for (int n = 2; n <= 200 && first < 0; n++)
        if (throwsOutOf(n, 2000, 5, 42L) + throwsOutOf(n, 2000, 3, 42L) > 0) first = n;
    IO.println("first size that ever throws (n = 2..200, 4000 inputs each): " + first);
    IO.println("TimSort MIN_MERGE (the JDK constant that explains it):      32");
}
