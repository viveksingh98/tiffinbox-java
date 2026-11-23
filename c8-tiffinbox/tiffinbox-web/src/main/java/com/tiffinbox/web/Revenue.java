package com.tiffinbox.web;

import org.springframework.context.annotation.Profile;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Course 8, unit 19 - the revenue per customer, grouped by MongoDB's server, under the profile "dev": the same orders the start
 * placed, copied into the collection orders (OrderDocument), through Boot's MongoTemplate. GET /revenue/by-customer runs an
 * aggregation pipeline - stages the server runs in order over a collection, each feeding the next: $group by customer, summing each order's
 * value into total, then $sort by total, highest first - and answers the groups as JSON, one {"customer", "total"} per customer
 * (200). The sum of the totals is not the route's: it is the number /kitchen's ordersValue already prints, and the receipt adds the
 * totals up beside it (../c8-unit19, anchor and pipeline). Not GET /revenue: that route is TiffinBoxServer's, the month's revenue
 * the database computes from the customers, on every run - unchanged, and one of the seven the units compare.
 *
 * <p>The aggregation is typed (newAggregation(OrderDocument.class, ...)): the mapper turns the Java field names the stages name
 * into the names stored in the documents. An untyped one sends the Java names as they are - on a field stored under another name,
 * the server groups on a field no document has and answers one group, null, with no error (../c8-unit19, silent).
 *
 * <p>TiffinBoxServer.start() fills the collection, as it fills Menus': reset(), then fill() with one OrderDocument per order it
 * places. Why the fill resets: the ids are the kitchen orders' and repeat at every start - a second start inserting them again
 * meets its own ids (../c8-unit19, twice); reset() removes every document first, a delete with an empty query, never a drop (a
 * drop would take the collection's indexes with it).
 *
 * <p>Why the profile "dev": under the profile dev, Mongo is required. The default run has no Revenue bean, no /revenue/by-customer
 * (404) and builds no MongoClient (../c8-unit19, default).
 *
 * <p>Course 8, unit 26: the pipeline is no longer here. It lives in OrderTotalsImpl, the class of OrderDocuments' fragment
 * OrderTotals, and the route reads it through the repository - orders.totalsByCustomer() - into CustomerTotal, which replaces
 * Revenue.Total with the same two components. The pipeline paragraphs above describe that class's pipeline now, stage for stage; the
 * route's JSON is the same, byte for byte, before and after the move (../c8-unit26, anchor). MongoTemplate stays here for reset() and
 * fill().
 */
@RestController
@Profile("dev")
public class Revenue {

    private final MongoTemplate mongo;
    private final OrderDocuments orders;

    Revenue(MongoTemplate mongo, OrderDocuments orders) {
        this.mongo = mongo;
        this.orders = orders;
    }

    /** Every document of the collection orders removed - a delete with an empty query; the collection and its indexes stay. */
    public void reset() {
        mongo.remove(new Query(), OrderDocument.class);
    }

    /** The copied orders inserted (insertAll). */
    public void fill(List<OrderDocument> orders) {
        mongo.insertAll(orders);
    }

    /** 200 and the groups, highest total first - the repository's fragment, OrderTotals.totalsByCustomer(). */
    @GetMapping("/revenue/by-customer")
    List<CustomerTotal> revenue() {
        return orders.totalsByCustomer();
    }
}
