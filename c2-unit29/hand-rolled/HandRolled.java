// The previous unit's JSON "parser", copied line for line out of AsyncCalls.java.
// Same four fields every time. Same values. Valid JSON in all three cases.
static final String TIGHT   = "{\"name\":\"Ravi\",\"mealsPerDay\":2,\"pricePerMeal\":120,\"veg\":true}";
static final String REORDER = "{\"veg\":true,\"name\":\"Ravi\",\"mealsPerDay\":2,\"pricePerMeal\":120}";
static final String STRINGY = "{\"name\":\"Ravi\",\"mealsPerDay\":2,\"pricePerMeal\":\"120\",\"veg\":true}";

static int field(String json, String key) {
    int at   = json.indexOf("\"" + key + "\"");
    int from = json.indexOf(':', at) + 1;
    int to   = json.indexOf(',', from);
    return Integer.parseInt(json.substring(from, to).trim());
}

static void bill(String label, String json) {
    try {
        IO.println(label + field(json, "mealsPerDay") * field(json, "pricePerMeal") * 30);
    } catch (RuntimeException e) {
        IO.println(label + e.getClass().getName());
        IO.println("                            " + e.getMessage());
    }
}

void main() {
    bill("as the last unit sent it -> ", TIGHT);
    bill("same fields, reordered   -> ", REORDER);
    bill("price sent as text       -> ", STRINGY);
}
