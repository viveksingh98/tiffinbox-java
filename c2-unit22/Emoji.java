// One character, three different counts - and a substring that cuts it in half.
// Run:  java Emoji.java
import java.text.BreakIterator;
import java.nio.charset.StandardCharsets;

String hex(int cp) {
    return "U+" + Integer.toHexString(cp).toUpperCase();
}

int graphemes(String s) {
    BreakIterator it = BreakIterator.getCharacterInstance(Locale.ROOT);
    it.setText(s);
    int n = 0;
    while (it.next() != BreakIterator.DONE) {
        n++;
    }
    return n;
}

void main() {
    String box = "🍱";                 // the bento box - a tiffin box in Unicode
    IO.println("the string                  : " + box);
    IO.println("length()                    : " + box.length());
    IO.println("codePointCount(0, length()) : " + box.codePointCount(0, box.length()));
    IO.println("chars().count()             : " + box.chars().count());
    IO.println("codePoints().count()        : " + box.codePoints().count());
    IO.println("getBytes(UTF_8).length      : " + box.getBytes(StandardCharsets.UTF_8).length);
    IO.println("codePointAt(0) as hex       : " + hex(box.codePointAt(0)));
    IO.println("charAt(0) as hex            : " + hex(box.charAt(0)));
    IO.println("charAt(1) as hex            : " + hex(box.charAt(1)));
    IO.println("isHighSurrogate(charAt(0))  : " + Character.isHighSurrogate(box.charAt(0)));

    String line = "Priya " + box;
    IO.println("\"Priya \" + box  length()    : " + line.length());
    IO.println("substring(0, 7)             : [" + line.substring(0, 7) + "]  <- half an emoji");

    String cook = "👨‍🍳";   // man + zero-width joiner + cooking
    IO.println("cook emoji                  : " + cook);
    IO.println("cook length()               : " + cook.length());
    IO.println("cook codePointCount         : " + cook.codePointCount(0, cook.length()));
    IO.println("cook grapheme clusters      : " + graphemes(cook));
}
