package com.tiffinbox.web;

import org.springframework.data.annotation.Id;

/**
 * Course 8, unit 26 - one group of the totals pipeline: the customer - the group's _id, hence {@code @Id} - and the sum of her orders'
 * values. Revenue.Total until unit 26, the same two components; a record of its own since, because OrderTotals, the repository's
 * fragment, answers it and the route only passes it on. GET /revenue/by-customer writes it as {"customer", "total"}, as before.
 */
public record CustomerTotal(@Id String customer, long total) {
}
