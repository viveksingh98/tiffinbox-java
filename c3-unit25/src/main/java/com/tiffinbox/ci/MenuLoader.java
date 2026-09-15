package com.tiffinbox.ci;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/**
 * One line of this class is the bug the CI unit is built on, and it is a bug you cannot
 * see by reading it.
 *
 * <p>The file on disk is {@code src/main/resources/Menu.json}, with a capital M. The name
 * asked for below is {@code /menu.json}, with a small one. On a Mac that difference does
 * not exist — the default APFS volume is case-INSENSITIVE, so the file opens, the test
 * passes, and the build is green. Three other places disagree:
 *
 * <ul>
 *   <li><b>inside a jar</b> — a zip entry name is an exact byte string, on every operating
 *       system. The same classes, packaged, cannot find the same file.</li>
 *   <li><b>on a case-sensitive volume</b> — which you can make on this very Mac in one
 *       command, and which every Linux CI runner already is.</li>
 *   <li><b>on the runner</b> — which is the first place most teams find out.</li>
 * </ul>
 *
 * <p>Nothing about this is exotic. It is the single most common "works on my machine" and
 * it survives code review every time, because the two spellings are never on screen
 * together.
 */
public final class MenuLoader {

    /** The name as the code asks for it. Lower case. */
    public static final String RESOURCE = "/menu.json";

    private MenuLoader() {
    }

    /** @return the raw menu document, or throws if the classpath does not have it. */
    public static String load() throws IOException {
        try (InputStream in = MenuLoader.class.getResourceAsStream(RESOURCE)) {
            if (in == null) {
                throw new IOException("menu resource not found on the classpath: " + RESOURCE);
            }
            return new String(in.readAllBytes(), StandardCharsets.UTF_8);
        }
    }

    /** @return how many meal types the menu document declares. */
    public static int mealTypes() throws IOException {
        String doc = load();
        int n = 0;
        for (String key : new String[] {"\"veg\"", "\"nonVeg\"", "\"vegan\""}) {
            if (doc.contains(key)) {
                n++;
            }
        }
        return n;
    }

    public static void main(String[] args) throws IOException {
        System.out.println("menu resource asked for: " + RESOURCE);
        System.out.println("meal types declared: " + mealTypes());
        System.out.println("ok");
    }
}
