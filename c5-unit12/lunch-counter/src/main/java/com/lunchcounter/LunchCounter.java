package com.lunchcounter;

import com.tiffinbox.kitchen.Kitchen;
import java.util.Arrays;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Lunch counter never names the starter's configuration class. It only asks for a Kitchen. */
@SpringBootApplication
public class LunchCounter {
    public static void main(String[] args) {
        try (var ctx = SpringApplication.run(LunchCounter.class, args)) {
            System.out.println("Kitchen beans: " + Arrays.toString(ctx.getBeanNamesForType(Kitchen.class))
                    + " -> " + ctx.getBean(Kitchen.class).describe());
        }
    }
}
