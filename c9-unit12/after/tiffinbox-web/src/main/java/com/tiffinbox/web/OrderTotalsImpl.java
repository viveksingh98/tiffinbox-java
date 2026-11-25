package com.tiffinbox.web;

import static org.springframework.data.mongodb.core.aggregation.Aggregation.group;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.newAggregation;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.sort;

import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;

import java.util.List;

/**
 * Course 8, unit 26 - OrderTotals' implementation, the fragment's class: the pipeline Revenue ran since unit 19, moved here unchanged
 * and typed on OrderDocument - $group by customer with $sum of value into total, then $sort by total, descending - its groups mapped
 * to CustomerTotal. MongoTemplate comes in through the constructor. No {@code @Component} and no {@code @Repository}: Spring Data
 * Commons finds this class by its name - OrderTotals and the postfix Impl - in OrderDocuments' package, and the repository's proxy
 * hands totalsByCustomer() to it (../c8-unit26, composition).
 */
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
