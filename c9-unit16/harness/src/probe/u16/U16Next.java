package probe.u16;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.ApplicationContext;
import org.springframework.hateoas.Link;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.reflect.Method;
import java.lang.reflect.RecordComponent;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;

/**
 * THE HARNESS'S PAGE ROUTE (Course 9 unit 16's receipts; never shipped): unit 13's own first page, taken from the app's OrderPages bean
 * (package-private and final: reached by reflection), with its next cursor turned into a link by the Method form on the FINAL OrderPages
 * - linkTo(OrderPages.class, orderPage, "newest", null, null, cursor, null) - so no proxy is made. The shipped GET /api/v1/orders is
 * not touched: its answer keeps next as a cursor string.
 */
@RestController
public class U16Next {

    private final ApplicationContext ctx;

    public U16Next(ApplicationContext ctx) {
        this.ctx = ctx;
    }

    @GetMapping("/probe/u16/orders")
    public Map<String, Object> page(HttpServletRequest request) throws Exception {
        Class<?> pages = Class.forName("com.tiffinbox.web.OrderPages");
        Object bean = ctx.getBean(pages);
        Method m = pages.getDeclaredMethod("orderPage", String.class, String.class, Integer.class, String.class, HttpServletRequest.class);
        m.setAccessible(true);
        Object page = m.invoke(bean, "newest", null, null, null, request); // this request: it carries no query parameter, as the list requires
        List<?> items = null; String next = null;
        for (RecordComponent c : page.getClass().getRecordComponents()) {
            c.getAccessor().setAccessible(true);
            Object v = c.getAccessor().invoke(page);
            if (c.getName().equals("items")) items = (List<?>) v;
            if (c.getName().equals("next")) next = (String) v;
        }
        var ids = new java.util.ArrayList<Object>();
        for (Object o : items) {
            var a = o.getClass().getRecordComponents()[0].getAccessor();
            a.setAccessible(true);
            ids.add(a.invoke(o));
        }
        Link link = linkTo(pages, m, "newest", null, null, next, null).withRel("next");
        var out = new LinkedHashMap<String, Object>();
        out.put("ids", ids);
        out.put("cursorLength", next == null ? 0 : next.length());
        // the Method form leaves the null optional parameters as a URI template ({&mealType,size}): expanded with no values, it is the
        // list's own next request
        out.put("next", Map.of("href", link.getHref(), "templated", link.isTemplated(), "expanded", link.expand().getHref()));
        return out;
    }
}
