import java.util.HashSet;
import java.util.Map;
import java.util.Set;

void main() {
    Set<String> phones = new HashSet<>();
    IO.println(phones.add("98200 11111"));
    IO.println(phones.add("98200 22222"));
    IO.println(phones.add("98200 11111"));
    IO.println(phones.size() + " unique: " + phones);
    var zones = Map.of("Ravi", "north", "Meera", "south");
    IO.println(zones.get("Meera"));
}
