package probe.v.rename2;

import jakarta.persistence.*;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;

/** Unit 35's variant "rename2": the anchor's customer table, mapped by an entity of the harness's with one change - mealsPerDay renamed to a nullable Integer mealsDaily (the column meals_daily). */
@SpringBootApplication
@EntityScan("probe.v.rename2")
public class VMain {
    public static void main(String[] args) { probe.d.Run.run(VMain.class, args); }

    @Entity
    @Table(name = "customer")
    public static class VCustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 60, nullable = false, unique = true) String name;
        Integer mealsDaily;
        int pricePerMeal;
        @Enumerated(EnumType.STRING) @Column(length = 10, nullable = false) com.tiffinbox.MealType mealType;
        @Version Long version;
    }
}
