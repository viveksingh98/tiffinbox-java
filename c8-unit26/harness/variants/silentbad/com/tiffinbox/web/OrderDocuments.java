package com.tiffinbox.web;

import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

/** The harness's variant (unit 26, silent - never shipped): the shipped repository with a second fragment, OrderLookup, mixed in. */
public interface OrderDocuments extends MongoRepository<OrderDocument, String>, OrderTotals, OrderLookup {

    List<OrderDocument> findByMealType(String mealType);
}
