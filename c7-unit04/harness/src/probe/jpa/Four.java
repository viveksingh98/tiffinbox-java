package probe.jpa;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * The persistence context lesson's harness, never TiffinBox's: joined to a run by --spring.main.sources=probe.jpa.Four. It
 * imports the first-entity lesson's Probe (its Steps, unchanged, act only on --probe.steps), this lesson's Pc (acts only on
 * --probe.pc) and Web (one route, GET /probe/twofinds).
 */
@Configuration
@Import({Probe.class, Pc.class, Web.class})
public class Four {
}
