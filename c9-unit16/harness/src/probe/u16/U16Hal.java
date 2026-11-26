package probe.u16;

import com.tiffinbox.OrderEntity;
import com.tiffinbox.OrderEntityRepository;
import org.springframework.data.domain.Limit;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Sort;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.Link;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.reflect.Method;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

/**
 * THE HARNESS'S ROUTES (Course 9 unit 16's receipts; never in the jar, the module, after or c9-tiffinbox), adapted from unit 15's
 * U15Hal: the final census's three link forms on the app's own classes (/probe/u16/final), and the app's twenty orders as one HAL
 * collection (/probe/u16/hal-all), an answer above Boot's compression floor. CustomerReads and OrderResources are package-private in
 * com.tiffinbox.web: reached by reflection.
 */
@RestController
public class U16Hal {

    /** One order as the harness's collection shows it (the shipped OrderView is package-private). */
    public record Row(Long id, String customer, String mealType, int amount, Instant placedAt) {
    }

    private final OrderEntityRepository orders;

    public U16Hal(OrderEntityRepository orders) {
        this.orders = orders;
    }

    /** methodOn() on the final CustomerReads, the Method form on it, and methodOn() on the non-final OrderResources - printed, not thrown. */
    @GetMapping("/probe/u16/final")
    public Map<String, Object> onFinal() throws Exception {
        var out = new LinkedHashMap<String, Object>();
        Class<?> reads = Class.forName("com.tiffinbox.web.CustomerReads");
        Method one = reads.getDeclaredMethod("one", String.class);
        one.setAccessible(true);
        try {
            Object proxy = methodOn(reads);
            out.put("methodOnFinal", linkTo(one.invoke(proxy, "Ravi")).withSelfRel().getHref());
        } catch (Throwable t) {
            out.put("methodOnFinal", t.getClass().getName() + ": " + t.getMessage());
            Throwable r = t; while (r.getCause() != null) r = r.getCause();
            out.put("methodOnFinalRoot", r.getClass().getName() + ": " + r.getMessage());
            System.out.println("U16 harness: methodOn(CustomerReads) -> " + t.getClass().getName() + ": " + t.getMessage());
            System.out.println("U16 harness: its root -> " + r.getClass().getName() + ": " + r.getMessage());
        }
        out.put("methodFormFinal", linkTo(reads, one, "Ravi").withSelfRel().getHref());
        Class<?> res = Class.forName("com.tiffinbox.web.OrderResources");
        Method or = res.getDeclaredMethod("orderResource", Long.class, jakarta.servlet.http.HttpServletRequest.class);
        or.setAccessible(true);
        Object p = methodOn(res);
        out.put("methodOnNonFinal", linkTo(or.invoke(p, 1L, null)).withSelfRel().getHref());
        var fin = new LinkedHashMap<String, Object>();   // in a fixed order (Map.of's order changes from one JVM to the next)
        fin.put("CustomerReads", java.lang.reflect.Modifier.isFinal(reads.getModifiers()));
        fin.put("OrderResources", java.lang.reflect.Modifier.isFinal(res.getModifiers()));
        out.put("finalModifier", fin);
        return out;
    }

    /** Every order (the app's own twenty, by id), each with its self link, as one HAL collection. */
    @GetMapping(value = "/probe/u16/hal-all", produces = {"application/hal+json", MediaType.APPLICATION_JSON_VALUE})
    public CollectionModel<EntityModel<Row>> all() throws Exception {
        Class<?> res = Class.forName("com.tiffinbox.web.OrderResources");
        Method or = res.getDeclaredMethod("orderResource", Long.class, jakarta.servlet.http.HttpServletRequest.class);
        List<OrderEntity> all = orders.findBy(ScrollPosition.keyset(), Sort.by("id"), Limit.of(50)).getContent();
        List<EntityModel<Row>> items = all.stream().map(o -> EntityModel.of(
                new Row(o.getId(), o.getCustomer(), o.getMealType().name(), o.getAmount(), o.getPlacedAt()),
                linkTo(res, or, o.getId(), null).withSelfRel())).toList();
        Link self = linkTo(U16Hal.class).slash("probe").slash("u16").slash("hal-all").withSelfRel();
        return CollectionModel.of(items, self);
    }
}
