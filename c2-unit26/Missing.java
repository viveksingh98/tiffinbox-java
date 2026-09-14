import java.nio.file.Files;
import java.nio.file.Path;

void main() throws Exception {
    Path menus = Path.of("menus");
    IO.println("does menus/ exist? " + Files.exists(menus));
    IO.println("reading menus/week-9.csv ...");
    IO.println(Files.readString(menus.resolve("week-9.csv")));
}
