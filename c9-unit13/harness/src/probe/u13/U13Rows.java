package probe.u13;

import com.tiffinbox.MealType;
import com.tiffinbox.OrderEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** THE HARNESS: the harness's insert - n orders placed now (later than every V6 row), between a reader's pages. No public write route. */
@RestController
class U13Rows {

    private final U13OrderRepository orders;

    U13Rows(U13OrderRepository orders) {
        this.orders = orders;
    }

    @PostMapping("/probe/u13/orders")
    Map<String, Object> insert(@RequestParam(defaultValue = "2") int n) {
        List<Long> ids = new ArrayList<>();
        Instant now = Instant.now();
        for (int i = 0; i < n; i++) ids.add(orders.save(new OrderEntity("Asha", MealType.VEG, 220, now.plusMillis(i))).getId());
        System.out.println("U13 harness: the harness's insert " + ids);
        return Map.of("inserted", ids);
    }
}
