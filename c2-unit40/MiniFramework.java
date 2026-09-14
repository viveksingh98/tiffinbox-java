import java.lang.reflect.Method;
import java.lang.reflect.RecordComponent;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class MiniFramework {

    // 1. SCAN — find every method that declared itself a route.
    static Map<String, Method> scan(Class<?> type) {
        Map<String, Method> routes = new TreeMap<>();
        for (Method m : type.getDeclaredMethods()) {
            Route r = m.getAnnotation(Route.class);
            if (r == null) continue;
            routes.put(r.method() + " " + r.path(), m);
        }
        return routes;
    }

    // 2. VALIDATE — the record's own components carry the rules.
    static List<String> validate(Record row) {
        List<String> problems = new ArrayList<>();
        for (RecordComponent rc : row.getClass().getRecordComponents()) {
            try {
                Object value = rc.getAccessor().invoke(row);
                if (rc.getAnnotation(NotBlank.class) != null
                        && String.valueOf(value).isBlank()) {
                    problems.add(rc.getName() + ": must not be blank");
                }
                Range range = rc.getAnnotation(Range.class);
                if (range != null) {
                    int n = (int) value;
                    if (n < range.min() || n > range.max()) {
                        problems.add(rc.getName() + ": " + n + " is outside "
                                + range.min() + ".." + range.max());
                    }
                }
            } catch (ReflectiveOperationException e) {
                throw new RuntimeException(e);
            }
        }
        return problems;
    }

    // 3. DISPATCH — look the key up, invoke the method.
    static String dispatch(Map<String, Method> routes, Object app, String key) throws Exception {
        Method m = routes.get(key);
        if (m == null) return "404 no handler";
        return (String) m.invoke(app);
    }

    public static void main(String[] args) throws Exception {
        Handlers app = new Handlers();
        Map<String, Method> routes = scan(Handlers.class);

        for (Map.Entry<String, Method> e : routes.entrySet()) {
            System.out.println(e.getKey() + "  ->  " + e.getValue().getName() + "()");
        }
        System.out.println("routes: " + routes.size() + " of "
                + Handlers.class.getDeclaredMethods().length + " methods");
        System.out.println();

        System.out.println("GET /revenue  ->  " + dispatch(routes, app, "GET /revenue"));
        System.out.println("POST /orders  ->  " + dispatch(routes, app, "POST /orders"));
        System.out.println("GET /pauses  ->  " + dispatch(routes, app, "GET /pauses"));
        System.out.println();

        System.out.printf("%-10s%s%n", "Ravi:", validate(new Customer("Ravi", 2, 120, true)));
        System.out.printf("%-10s%s%n", "bad row:", validate(new Customer(" ", 9, 20, true)));
        System.out.println();

        Route r = Handlers.class.getDeclaredMethod("placeOrder").getAnnotation(Route.class);
        System.out.println(r);
        System.out.println("retention: " + Route.class.getAnnotation(java.lang.annotation.Retention.class).value());
        System.out.println("targets:   " + java.util.Arrays.toString(
                Route.class.getAnnotation(java.lang.annotation.Target.class).value()));
    }
}
