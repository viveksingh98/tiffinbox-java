package com.tiffinbox.harness;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * What the configuration processor wrote. {@code Metadata <jar> <the record's source file>}.
 *
 * <p>Reads {@code META-INF/spring-configuration-metadata.json} out of the jar (with Jackson, which is on TiffinBox's class
 * path) and prints how many entries each of its sections holds, the group, and every property with its type, its
 * default value (or none) and its description. Then two checks against the record's source file: is each description
 * the text of the record's {@code @param} line for that component, word for word; and which components are declared
 * {@code int}, and does the file give each of them a default value of 0. It starts no application.
 */
public final class Metadata {

    private static final String FILE = "META-INF/spring-configuration-metadata.json";

    public static void main(String[] args) throws Exception {
        JsonNode root;
        try (JarFile jar = new JarFile(args[0])) {
            JarEntry e = jar.getJarEntry(FILE);
            if (e == null) {
                System.out.println("no " + FILE + " in " + Path.of(args[0]).getFileName());
                return;
            }
            root = new ObjectMapper().readTree(jar.getInputStream(e));
        }
        String source = Files.readString(Path.of(args[1]));
        System.out.println("its sections: groups " + root.path("groups").size() + " · properties " + root.path("properties").size()
                + " · hints " + root.path("hints").size() + " · ignored properties " + root.path("ignored").path("properties").size());
        for (JsonNode g : root.path("groups")) {
            System.out.println("group " + g.path("name").asText() + " · type " + g.path("type").asText());
        }
        for (JsonNode p : root.path("properties")) {
            System.out.println(String.format("  %-22s %-38s default %-5s \"%s\"", p.path("name").asText(), p.path("type").asText(),
                    p.has("defaultValue") ? p.path("defaultValue").toString() : "none", p.path("description").asText()));
        }

        // the record's @param lines: component -> text, and its components with their declared types
        Map<String, String> params = new LinkedHashMap<>();
        Matcher m = Pattern.compile("(?m)^\\s*\\*\\s*@param\\s+(\\w+)\\s+(.+?)\\s*$").matcher(source);
        while (m.find()) {
            params.put(m.group(1), m.group(2));
        }
        Matcher header = Pattern.compile("record\\s+\\w+\\s*\\(([^)]*)\\)").matcher(source);
        header.find();
        List<String> ints = new ArrayList<>();
        for (String component : header.group(1).split(",")) {
            String[] typeAndName = component.trim().split("\\s+");
            if (typeAndName[0].equals("int")) {
                ints.add(typeAndName[typeAndName.length - 1]);
            }
        }
        int same = 0;
        for (JsonNode p : root.path("properties")) {
            String component = camel(p.path("name").asText().substring(p.path("name").asText().indexOf('.') + 1));
            if (p.path("description").asText().equals(params.get(component))) {
                same++;
            }
        }
        System.out.println("the record's @param lines: " + params.size() + " · descriptions that are one of them, word for word, for the same component: "
                + same + " of " + root.path("properties").size());
        int zero = 0;
        for (String component : ints) {
            for (JsonNode p : root.path("properties")) {
                if (camel(p.path("name").asText().substring(p.path("name").asText().indexOf('.') + 1)).equals(component)
                        && p.has("defaultValue") && p.path("defaultValue").asInt(-1) == 0 && p.path("defaultValue").isInt()) {
                    zero++;
                }
            }
        }
        System.out.println("the record's int components: " + ints + " · given \"defaultValue\": 0 in the file: " + zero + " of " + ints.size());
    }

    /** meal-types -> mealTypes: the kebab-case key back to the record component's name. */
    private static String camel(String kebab) {
        StringBuilder s = new StringBuilder();
        boolean up = false;
        for (char c : kebab.toCharArray()) {
            if (c == '-') {
                up = true;
            } else {
                s.append(up ? Character.toUpperCase(c) : c);
                up = false;
            }
        }
        return s.toString();
    }
}
