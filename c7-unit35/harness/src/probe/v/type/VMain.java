package probe.v.type;

import jakarta.persistence.*;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;

/** Unit 35's variant "type": the anchor's customer table, mapped by an entity of the harness's with one change - mealsPerDay as a String on the integer column. */
@SpringBootApplication
@EntityScan("probe.v.type")
public class VMain {
    public static void main(String[] args) { probe.d.Run.run(VMain.class, args); }

    @Entity
    @Table(name = "customer")
    public static class VCustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 60, nullable = false, unique = true) String name;
        String mealsPerDay;
        int pricePerMeal;
        @Enumerated(EnumType.STRING) @Column(length = 10, nullable = false) com.tiffinbox.MealType mealType;
        @Version Long version;
    }
}
