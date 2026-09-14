import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg)
        implements Serializable {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
    String mealType() { return isVeg ? "VEG" : "NON_VEG"; }
    String csv() { return name + "," + mealsPerDay + "," + pricePerMeal + "," + mealType(); }
}

void main() throws Exception {
    Customer ravi = new Customer("Ravi", 2, 120, true);

    Path dir = Files.createTempDirectory(Path.of("."), "tiffinbox-ser-");
    Path bin = dir.resolve("ravi.ser");

    String line = ravi.csv();
    IO.println(line + "  -> " + line.getBytes(StandardCharsets.UTF_8).length + " bytes as CSV");

    try (var out = new ObjectOutputStream(Files.newOutputStream(bin))) {
        out.writeObject(ravi);
    }
    IO.println("ravi.ser        -> " + Files.size(bin) + " bytes as Java serialization");

    try (var in = new ObjectInputStream(Files.newInputStream(bin))) {
        Customer copy = (Customer) in.readObject();
        IO.println("read back       -> " + copy.name() + " " + copy.monthlyBill());
    }

    Files.delete(bin);
    Files.delete(dir);
}
