package trap;

import com.tiffinbox.kitchen.Kitchen;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

/** D: the same root, com.tiffinbox, scanned through @SpringBootApplication instead - and the same Kitchen bean. */
@SpringBootApplication(scanBasePackages = "com.tiffinbox")
public class SpringBootShape {

    @Bean
    Kitchen myKitchen() {
        return new Kitchen("TiffinBox's own kitchen", 2);
    }

    public static void main(String[] args) throws Exception {
        Kitchens.run(SpringBootShape.class, args);
    }
}
