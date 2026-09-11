import java.util.HashMap;
import java.util.Map;

void main() {
    Map<String, Integer> dues = new HashMap<>();
    dues.put("Ravi", 7200);
    dues.put("Meera", 4500);
    dues.put("Sunil", 3600);
    IO.println(dues.get("Meera"));
    dues.put("Meera", 4800);
    IO.println(dues);
    IO.println(dues.containsKey("Asha") + " " + dues.size());
    IO.println(dues.get("Asha"));
    IO.println(dues.getOrDefault("Asha", 0));
    dues.merge("Ravi", 240, Integer::sum);
    IO.println(dues.get("Ravi"));
    for (var entry : dues.entrySet()) IO.println(entry.getKey() + " owes " + entry.getValue());
}
