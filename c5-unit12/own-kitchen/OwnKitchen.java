package com.lunchcounter;

import com.tiffinbox.kitchen.Kitchen;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** Lunch counter's own kitchen: one more file, in lunch counter's own package, where its scan looks. */
@Configuration
class OwnKitchen {
    @Bean
    Kitchen myKitchen() {
        return new Kitchen("Lunch counter's own kitchen", 2);
    }
}
