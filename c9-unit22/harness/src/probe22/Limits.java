// Course 9 unit 22's limits reader (HARNESS, never shipped): Jackson 3's read constraints as the library defines them
// (tools.jackson.core.StreamReadConstraints.defaults(), every public getMax* read by reflection) - the library's defaults, not a
// running TiffinBox's mapper. Run: java -cp <the web jar's BOOT-INF/lib/*> harness/src/probe22/Limits.java
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.Comparator;

public class Limits {
    public static void main(String[] a) throws Exception {
        Class<?> k = Class.forName("tools.jackson.core.StreamReadConstraints");
        Object d = k.getMethod("defaults").invoke(null);
        Method[] ms = k.getMethods();
        Arrays.sort(ms, Comparator.comparing(Method::getName));
        for (Method m : ms) {
            if (m.getName().startsWith("getMax") && m.getParameterCount() == 0) {
                System.out.println("LIMIT " + k.getSimpleName() + "." + m.getName() + "() = " + m.invoke(d));
            }
        }
        Class<?> v = Class.forName("tools.jackson.core.json.PackageVersion");
        System.out.println("LIMIT jackson-core " + v.getField("VERSION").get(null) + " (" + k.getProtectionDomain().getCodeSource().getLocation().getPath().replaceAll(".*/", "") + ")");
    }
}
