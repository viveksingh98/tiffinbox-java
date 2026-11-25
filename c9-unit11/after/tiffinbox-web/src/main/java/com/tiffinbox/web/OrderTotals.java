package com.tiffinbox.web;

import java.util.List;

/**
 * Course 8, unit 26 - a repository fragment: an interface of your own, and a class named after it, whose method the repository hands
 * to that class. OrderDocuments extends it beside MongoRepository, so the repository answers totalsByCustomer() too - the one method
 * on it no derived name can say: a $group by customer with a $sum of each order's value, then a $sort by the total, highest first.
 *
 * <p>The class is OrderTotalsImpl: this interface's name and Spring Data Commons' default postfix, Impl (the default of
 * {@code repositoryImplementationPostfix} on {@code @EnableMongoRepositories}). Commons finds it by that name in the repository's
 * package and puts it in the repository's composition before Spring Data MongoDB's SimpleMongoRepository; a call to
 * totalsByCustomer() goes through RepositoryComposition to OrderTotalsImpl (../c8-unit26, composition). Named another way, no class
 * is found, and Spring Data MongoDB reads the method's name as a derived query and stops the start - No property 'totalsByCustomer'
 * found for type 'OrderDocument' (../c8-unit26, misnamed).
 */
public interface OrderTotals {

    /** The four customers' totals, highest first - one aggregate on orders, grouped by MongoDB's server. */
    List<CustomerTotal> totalsByCustomer();
}
