package com.tiffinbox.web;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * Course 8, unit 19 - Document and search: one order the start placed, copied into MongoDB's collection orders, under the profile
 * "dev". The orders are the kitchen's own - the start places one per customer per day, and /kitchen, the start's "kitchen value"
 * line and the Redis leaderboard already add their values up. PostgreSQL stays the system of record for the customers; this
 * collection holds no order of its own, only a copy of the ones the start placed, refilled at every start (TiffinBoxServer), so
 * that MongoDB's server can group them (Revenue).
 *
 * <p>Its id is the kitchen order's id - the customer and the day, Ravi-1 to Ravi-30, as KitchenOrder's - a String the start
 * chooses, so every start writes the same 120 ids. The customer is the name, the meal type the customer's own String (VEG, NON_VEG,
 * VEGAN - stored as that String, the form a filter on it names), the day 1 to tiffinbox.days, the value the order's: its meals
 * times its price. The mapper writes _class too, the type hint it reads the document back with: com.tiffinbox.web.OrderDocument.
 * No index but the one on _id: unit 20 measures what a query on customer reads without one.
 *
 * <p>Why the profile "dev": Revenue, which writes and groups this collection, exists under "dev" only, where Mongo is required;
 * the default run has no orders collection and builds no MongoClient (../c8-unit19, default). Named OrderDocument, not
 * KitchenOrder: that is the Redis entity of the same order (unit 15).
 */
@Document("orders")
public record OrderDocument(@Id String id, String customer, String mealType, int day, int value) {
}
