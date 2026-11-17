package probe.u03;

import com.tiffinbox.jdbc.CustomerRow;
import org.springframework.data.annotation.Id;
import org.springframework.data.jdbc.core.mapping.AggregateReference;
import org.springframework.data.relational.core.mapping.Table;

/**
 * Unit 03's sketch, never the anchor's: a pause read as an aggregate of its own, over V1's pause table, that refers to its
 * customer - another aggregate - by id alone: AggregateReference<CustomerRow, Long>, column customer_id (the default naming
 * strategy's snake case of customerId). It holds no CustomerRow object; loading it loads no customer.
 */
@Table("pause")
public class PauseRef {

    @Id
    Long id;

    int days;

    AggregateReference<CustomerRow, Long> customerId;

    protected PauseRef() {
    }

    PauseRef(int days, AggregateReference<CustomerRow, Long> customerId) {
        this.days = days;
        this.customerId = customerId;
    }
}
