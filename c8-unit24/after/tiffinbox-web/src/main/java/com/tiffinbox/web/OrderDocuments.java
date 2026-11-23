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
 */
public interface OrderDocuments extends MongoRepository<OrderDocument, String> {

    /** Every copied order of one meal type - one find, filter {mealType: the value}. */
    List<OrderDocument> findByMealType(String mealType);
}
