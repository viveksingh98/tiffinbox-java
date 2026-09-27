package contrast;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * For contrast only - deliberately OUTSIDE com.tiffinbox, so the capstone's @ComponentScan never sees it.
 * The capstone's configuration class has no @Bean method; this one has exactly one.
 */
@Configuration
public class OneBeanMethod {
    @Bean
    String greeting() { return "hello"; }
}
