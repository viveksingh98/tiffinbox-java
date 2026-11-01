package probe.jpa;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * The course's harness, never TiffinBox's: joined to a run by --spring.main.sources=probe.jpa.Probe (outside com.tiffinbox,
 * so TiffinBox's component scan never finds it). It does nothing unless the run sets --probe.steps (Steps).
 */
@Configuration
@Import(Steps.class)
public class Probe {
}
