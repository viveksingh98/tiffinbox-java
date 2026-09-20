package com.tiffinbox;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * THE ANSWER: the scope. A prototype is handed to whoever asked for it and then forgotten —
 * the container keeps no reference to it, so it has nothing to call a destroy callback on and
 * never claimed it would. The freezer is one freezer; it was never a per-use object.
 *
 * <p>If a thing really is per-use AND holds a resource, the container will not close it for
 * you and the closing is yours to do — which is the one case where try-with-resources is
 * still the right answer inside a container.
 */
@Configuration
public class FreezerConfig {

    @Bean
    Freezer freezer() { return new Freezer(); }
}
