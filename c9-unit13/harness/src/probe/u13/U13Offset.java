package probe.u13;

import com.tiffinbox.OrderEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * THE HARNESS: the harness's offset route - the loser. Page numbers over the same sorts; the id added as the tie-break in the SORT'S
 * OWN direction (newest first: placed_at desc, id desc - RED #24), so its tie order differs from the cursor route's (id ascending).
 */
@RestController
class U13Offset {

    private final U13OrderRepository orders;

    U13Offset(U13OrderRepository orders) {
        this.orders = orders;
    }

    @GetMapping("/probe/u13/orders/by-page")
    Map<String, Object> page(@RequestParam(defaultValue = "newest") String sort, @RequestParam(defaultValue = "0") int page,
                             @RequestParam(defaultValue = "5") int size) {
        Sort.Direction d = sort.equals("oldest") ? Sort.Direction.ASC : Sort.Direction.DESC;
        Sort s = Sort.by(d, "placedAt").and(Sort.by(d, "id"));
        Page<OrderEntity> p = orders.findAll(PageRequest.of(page, size, s));
        var out = new LinkedHashMap<String, Object>();
        out.put("items", p.getContent().stream().map(U13Offset::row).toList());
        out.put("page", page);
        out.put("total", p.getTotalElements());
        return out;
    }

    static Map<String, Object> row(OrderEntity o) {
        var m = new LinkedHashMap<String, Object>();
        m.put("id", o.getId());
        m.put("amount", o.getAmount());
        return m;
    }
}
