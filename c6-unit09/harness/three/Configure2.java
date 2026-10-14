package probe.three;

import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.ObjectMapper;

/**
 * The course's harness. Core Java II's Jackson lesson made a lenient mapper with this line (its JsonOops.java), against
 * Jackson 2: new ObjectMapper().configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false). Here it is unchanged
 * but for the two imports, which name Jackson 3's packages, and it is compiled against the jar's Jackson 3 - where a mapper
 * is immutable once built, and has no configure. This file is meant not to compile: receipts.sh compiles it alone.
 */
public class Configure2 {
    public static void main(String[] args) {
        ObjectMapper lenient = new ObjectMapper()
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        System.out.println(lenient);
    }
}
