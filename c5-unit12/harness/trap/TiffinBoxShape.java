package trap;

import com.tiffinbox.kitchen.Kitchen;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * C: TiffinBoxApp's own three annotations, exactly as c5-tiffinbox carries them (its @PropertySource aside: no file is
 * read here), plus one Kitchen bean of its own. TiffinBox scans com.tiffinbox, and so the starter's package with it.
 */
@Configuration
@EnableAutoConfiguration
@ComponentScan("com.tiffinbox")
public class TiffinBoxShape {

    @Bean
    Kitchen myKitchen() {
        return new Kitchen("TiffinBox's own kitchen", 2);
    }

    public static void main(String[] args) throws Exception {
        Kitchens.run(TiffinBoxShape.class, args);
    }
}
