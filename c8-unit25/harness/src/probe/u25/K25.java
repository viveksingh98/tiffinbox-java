package probe.u25;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Window;

/**
 * Course 8, unit 25 - the harness's shared types (called by H25's facts mode, last): where Window and ScrollPosition load from (each
 * class's code source), and the shipped CustomerEntityRepository.findFirst10ByOrderByNameAsc(ScrollPosition.keyset()) - the first window,
 * between its own markers (PostgreSQL's log is the witness). Four customers under a limit of ten: no second window is asked for, so no
 * keyset predicate is claimed.
 */
final class K25 {

    private K25() {
    }

    static void types(ConfigurableApplicationContext ctx) {
        H25.p("TYPES Window's class " + Window.class.getName() + " from " + H25.jar(Window.class) + " · ScrollPosition's " + ScrollPosition.class.getName() + " from " + H25.jar(ScrollPosition.class));
        H25.mark(ctx, "keyset-jpa-begin");
        Window<com.tiffinbox.CustomerEntity> w = ctx.getBean(CustomerEntityRepository.class).findFirst10ByOrderByNameAsc(ScrollPosition.keyset());
        H25.mark(ctx, "keyset-jpa-end");
        H25.p("TYPES CustomerEntityRepository.findFirst10ByOrderByNameAsc(ScrollPosition.keyset()) -> the first window " + w.getContent().stream().map(e -> e.getName()).toList()
                + " · size " + w.size() + " · hasNext " + w.hasNext() + " · its class " + w.getClass().getName() + " from " + H25.jar(w.getClass()));
    }
}
