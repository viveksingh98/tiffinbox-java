import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

void main() throws Exception {
    Path menu = Files.createTempDirectory(Path.of("."), "tiffinbox-charset-").resolve("menu.txt");
    Files.writeString(menu, "TiffinBox menu: VEG, NON_VEG, VEGAN\n", StandardCharsets.UTF_16);
    IO.println("wrote as UTF-16:  " + Files.size(menu) + " bytes");
    IO.println("read as UTF-16:   " + Files.readString(menu, StandardCharsets.UTF_16).strip());
    IO.print  ("read as UTF-8 ... ");
    IO.println(Files.readString(menu).strip());
}
