import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
    String mealType() { return isVeg ? "VEG" : "NON_VEG"; }
}

void main() throws Exception {
    List<Customer> book = List.of(
            new Customer("Ravi",  2, 120, true),
            new Customer("Meera", 1, 150, true),
            new Customer("Sunil", 3, 100, false),
            new Customer("Priya", 1, 120, true));

    // a demo that writes files cleans up after itself: a temp dir beside this source file
    Path dir = Files.createTempDirectory(Path.of("."), "tiffinbox-io-");
    Path csv = dir.resolve("customers.csv");

    // WRITE: BufferedWriter -> OutputStreamWriter -> FileOutputStream -> disk
    try (var out = new BufferedWriter(
                       new OutputStreamWriter(
                           new FileOutputStream(csv.toFile()), StandardCharsets.UTF_8))) {
        out.write("name,mealsPerDay,pricePerMeal,mealType");
        out.newLine();
        for (Customer c : book) {
            out.write(c.name() + "," + c.mealsPerDay() + "," + c.pricePerMeal() + "," + c.mealType());
            out.newLine();
        }
    }
    IO.println("bytes on disk:  " + Files.size(csv));

    // READ: the same three classes, in reverse
    var back = new ArrayList<Customer>();
    try (var in = new BufferedReader(
                      new InputStreamReader(
                          new FileInputStream(csv.toFile()), StandardCharsets.UTF_8))) {
        in.readLine();                       // swallow the header
        String line;
        while ((line = in.readLine()) != null) {
            String[] f = line.split(",");
            back.add(new Customer(f[0], Integer.parseInt(f[1]), Integer.parseInt(f[2]),
                                  !f[3].equals("NON_VEG")));
        }
    }
    int total = 0;
    for (Customer c : back) {
        IO.println(c.name() + " -> " + c.monthlyBill());
        total += c.monthlyBill();
    }
    IO.println("month total:    " + total);

    // no decorator at all: a file really is just bytes
    try (var raw = new FileInputStream(csv.toFile())) {
        byte[] first = raw.readNBytes(12);
        IO.println("first 12 bytes: " + Arrays.toString(first));
    }

    Files.delete(csv);
    Files.delete(dir);
}
