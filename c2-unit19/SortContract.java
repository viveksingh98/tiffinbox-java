import java.util.*;

record Rating(String customer, int stars) {}

/// "less than or equal" is not "less than": this comparator never returns 0.
static final Comparator<Rating> BROKEN = (a, b) -> a.stars() <= b.stars() ? -1 : 1;

static List<Rating> ratings(int n) {
    var list = new ArrayList<Rating>();
    for (int i = 0; i < n; i++) list.add(new Rating("cust" + i, 1 + i % 3));
    return list;
}

static String stars(List<Rating> list) {
    var sb = new StringBuilder();
    for (Rating r : list) sb.append(r.stars());
    return sb.toString();
}

void main() {
    Rating x = new Rating("Meera", 5), y = new Rating("Priya", 5);
    IO.println("BROKEN.compare(x, x) = " + BROKEN.compare(x, x));
    IO.println("BROKEN.compare(x, y) = " + BROKEN.compare(x, y));
    IO.println("BROKEN.compare(y, x) = " + BROKEN.compare(y, x));

    var small = ratings(31);
    small.sort(BROKEN);
    IO.println("31 ratings sorted: no exception, stars now " + stars(small));

    IO.println("sorting 32 ratings with the same comparator ...");
    ratings(32).sort(BROKEN);
}
