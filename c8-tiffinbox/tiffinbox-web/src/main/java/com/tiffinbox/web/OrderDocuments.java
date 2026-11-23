package com.tiffinbox.web;

import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

/**
 * Course 8, unit 19 - a Spring Data MongoDB repository over the collection orders (OrderDocument), under the profile "dev": Boot's
 * MongoDB repository auto-configuration finds it in this package (TiffinBoxApp's), and with four Spring Data modules on the class
 * path each module claims only the interfaces it can safely identify - this one by OrderDocument's {@code @Document}.
 *
 * <p>findByMealType is a derived finder: Spring Data reads its name and sends ONE find on orders with the filter
 * {mealType: "VEG"} - the same find MongoTemplate.find sends for Criteria.where("mealType").is("VEG") (../c8-unit19, finder:
 * system.profile shows one query op for each, the same filter).
 *
 * <p>Course 8, unit 26: and a repository fragment beside the derived finder - OrderTotals, whose totalsByCustomer() no derived
 * name can say. The repository extends it; Spring Data Commons finds OrderTotalsImpl by its name in this package and composes the
 * repository from that class and Spring Data MongoDB's SimpleMongoRepository: a call to totalsByCustomer() goes to OrderTotalsImpl,
 * every other call to SimpleMongoRepository or to a query derived from its name (../c8-unit26, composition). Revenue's route reads
 * the totals through it.
 */
public interface OrderDocuments extends MongoRepository<OrderDocument, String>, OrderTotals {

    /** Every copied order of one meal type - one find, filter {mealType: the value}. */
    List<OrderDocument> findByMealType(String mealType);
}
