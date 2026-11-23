package com.tiffinbox.web;

import static org.springframework.data.mongodb.core.aggregation.Aggregation.group;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.newAggregation;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.sort;

import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

/** The harness's variant (unit 26, lookup a): the shipped OrderTotalsImpl, byte for byte but this line, the import and @Component. */
@Component
public class OrderTotalsImpl implements OrderTotals {

    private final MongoTemplate mongo;

    OrderTotalsImpl(MongoTemplate mongo) {
        this.mongo = mongo;
    }

    /** One aggregate on orders: $group by customer, $sum of value, $sort by total descending - the groups as CustomerTotal. */
    @Override
    public List<CustomerTotal> totalsByCustomer() {
        return mongo.aggregate(newAggregation(OrderDocument.class, group("customer").sum("value").as("total"), sort(Sort.Direction.DESC, "total")),
                CustomerTotal.class).getMappedResults();
    }
}
