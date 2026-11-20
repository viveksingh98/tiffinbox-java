package probe.u19;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

/**
 * The harness's copy of the shipped com.tiffinbox.web.OrderDocument (never TiffinBox's): the same five fields, with customer stored
 * under another name - {@code @Field("cust")} - in its own collection, orders_r, so the shipped orders stay as the start filled
 * them. field and silent read it: the typed aggregation maps customer to cust, the untyped one does not.
 */
@Document("orders_r")
public record OrderRenamed(@Id String id, @Field("cust") String customer, String mealType, int day, int value) {
}
