package com.tiffinbox;

/**
 * Course 7, unit 26: a customer was stored. CustomerRepository's add publishes it inside its transaction; a listener that asks
 * for the transaction's phase - CustomerFeed's, after the commit - hears it only once the row is in the database.
 */
public record CustomerAdded(Customer customer) {
}
