package probe.u13;

import com.tiffinbox.OrderEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/** THE HARNESS: the harness's Pageable route - Spring Data's own web support, Pageable bound from ?page=&size=&sort=, no whitelist. */
@RestController
class U13Pageable {

    private final U13OrderRepository orders;

    U13Pageable(U13OrderRepository orders) {
        this.orders = orders;
    }

    @GetMapping("/probe/u13/orders/pageable")
    Map<String, Object> pageable(Pageable pageable) {
        Page<OrderEntity> p = orders.findAll(pageable);
        var out = new LinkedHashMap<String, Object>();
        out.put("items", p.getContent().stream().map(U13Offset::row).toList());
        out.put("total", p.getTotalElements());
        return out;
    }
}
