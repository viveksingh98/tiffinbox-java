import java.util.HashMap;
import java.util.Map;

void main() {
    Map<String, Integer> dues = new HashMap<>();
    dues.put("Ravi", 7200);
    int due = dues.get("Asha");
    IO.println(due);
}
