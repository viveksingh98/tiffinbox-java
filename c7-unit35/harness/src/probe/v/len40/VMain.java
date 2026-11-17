package probe.v.len40;

import jakarta.persistence.*;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;

/** Unit 35's variant "len40": the anchor's customer table, mapped by an entity of the harness's with one change - name with @Column(length = 40) on the varchar(60) column. */
@SpringBootApplication
@EntityScan("probe.v.len40")
public class VMain {
    public static void main(String[] args) { probe.d.Run.run(VMain.class, args); }

    @Entity
    @Table(name = "customer")
    public static class VCustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 40, nullable = false, unique = true) String name;
        int mealsPerDay;
        int pricePerMeal;
        @Enumerated(EnumType.STRING) @Column(length = 10, nullable = false) com.tiffinbox.MealType mealType;
        @Version Long version;
    }
}
