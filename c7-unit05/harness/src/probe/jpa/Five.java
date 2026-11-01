package probe.jpa;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * The entity states lesson's harness, never TiffinBox's: joined to a run by --spring.main.sources=probe.jpa.Five. It imports
 * the first-entity lesson's Probe (its Steps, unchanged, act only on --probe.steps) and this lesson's St (acts only on
 * --probe.st).
 */
@Configuration
@Import({Probe.class, St.class})
public class Five {
}
