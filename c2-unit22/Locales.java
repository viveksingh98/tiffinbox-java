// toUpperCase() with no argument asks the machine what language it is in.
// Run:  java -Duser.language=en -Duser.country=US Locales.java
// Then: java -Duser.language=tr -Duser.country=TR Locales.java
import java.nio.charset.Charset;

void main() {
    Locale tr = Locale.forLanguageTag("tr-TR");
    IO.println("Locale.getDefault()             : " + Locale.getDefault());
    IO.println("\"priya\".toUpperCase()           : " + "priya".toUpperCase());
    IO.println("\"priya\".toUpperCase(Locale.ROOT): " + "priya".toUpperCase(Locale.ROOT));
    IO.println("\"priya\".toUpperCase(tr-TR)      : " + "priya".toUpperCase(tr));
    IO.println("match against \"PRIYA\"           : " + "priya".toUpperCase().equals("PRIYA"));
    IO.println("\"KIRAN\".toLowerCase(tr-TR)      : " + "KIRAN".toLowerCase(tr));
    IO.println("equalsIgnoreCase(\"PRIYA\")       : " + "priya".equalsIgnoreCase("PRIYA"));
    IO.println("Charset.defaultCharset()        : " + Charset.defaultCharset());
}
