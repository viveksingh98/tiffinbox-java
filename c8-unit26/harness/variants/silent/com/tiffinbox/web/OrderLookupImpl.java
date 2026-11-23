package com.tiffinbox.web;

import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.util.List;

/** The harness's variant (unit 26, silent): OrderLookup's class, named by the default postfix - the customer's last 7 days, newest first. */
public class OrderLookupImpl implements OrderLookup {

    private final MongoTemplate mongo;

    OrderLookupImpl(MongoTemplate mongo) {
        this.mongo = mongo;
    }

    @Override
    public List<OrderDocument> findByCustomer(String customer) {
        System.out.println("the harness's variant OrderLookupImpl.findByCustomer ran");
        return mongo.find(Query.query(Criteria.where("customer").is(customer)).with(Sort.by(Sort.Direction.DESC, "day")).limit(7), OrderDocument.class);
    }
}
