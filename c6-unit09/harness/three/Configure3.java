package probe.three;

import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.json.JsonMapper;

/**
 * The course's harness. The same lenient mapper, the Jackson 3 way: the setting goes on the builder, before the mapper exists,
 * and the mapper built from it is fixed - it prints the setting read back.
 */
public class Configure3 {
    public static void main(String[] args) {
        JsonMapper lenient = JsonMapper.builder()
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                .build();
        System.out.println(lenient.isEnabled(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES));
    }
}
