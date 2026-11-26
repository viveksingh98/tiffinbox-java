package probe.u13;

import com.tiffinbox.MealType;
import com.tiffinbox.OrderEntity;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Window;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * THE HARNESS: Course 7's offset-then-keyset trap on the pin, with same-method controls. mode=B: one method asked offset() then
 * keyset(); mode=A: the control, another method asked keyset() twice; mode=C: one method asked keyset(), offset(), keyset();
 * mode=Aprime: mode B's method asked keyset() only (run in a JVM of its own - Course 7's A-prime). Each step prints a marker line
 * before its SQL, so the SQL log is read step by step.
 */
@RestController
class U13Trap {

    private final U13OrderRepository orders;

    U13Trap(U13OrderRepository orders) {
        this.orders = orders;
    }

    private static List<Long> ids(Window<OrderEntity> w) {
        return w.getContent().stream().map(OrderEntity::getId).toList();
    }

    private static void mark(String s) {
        System.out.println("U13TRAP " + s);
    }

    @GetMapping("/probe/u13/trap")
    Map<String, Object> trap(@RequestParam String mode) {
        var out = new LinkedHashMap<String, Object>();
        switch (mode) {
            case "B" -> {
                mark("B offset");
                out.put("B offset", ids(orders.findFirst2ByCustomerOrderByAmountAsc("Ravi", ScrollPosition.offset())));
                mark("B keyset");
                out.put("B keyset", ids(orders.findFirst2ByCustomerOrderByAmountAsc("Ravi", ScrollPosition.keyset())));
            }
            case "A" -> {
                mark("A keyset");
                out.put("A keyset", ids(orders.findFirst2ByMealTypeOrderByAmountAsc(MealType.VEGAN, ScrollPosition.keyset())));
                mark("A keyset again");
                out.put("A keyset again", ids(orders.findFirst2ByMealTypeOrderByAmountAsc(MealType.VEGAN, ScrollPosition.keyset())));
            }
            case "C" -> {
                mark("C keyset");
                out.put("C keyset", ids(orders.findFirst2ByCustomerNotOrderByAmountAsc("Ravi", ScrollPosition.keyset())));
                mark("C offset");
                out.put("C offset", ids(orders.findFirst2ByCustomerNotOrderByAmountAsc("Ravi", ScrollPosition.offset())));
                mark("C keyset again");
                out.put("C keyset again", ids(orders.findFirst2ByCustomerNotOrderByAmountAsc("Ravi", ScrollPosition.keyset())));
            }
            case "Aprime" -> {
                mark("Aprime keyset");
                out.put("Aprime keyset", ids(orders.findFirst2ByCustomerOrderByAmountAsc("Ravi", ScrollPosition.keyset())));
            }
            default -> throw new IllegalArgumentException(mode);
        }
        mark("end");
        return out;
    }
}
