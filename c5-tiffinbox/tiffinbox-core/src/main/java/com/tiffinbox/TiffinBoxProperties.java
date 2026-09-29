package com.tiffinbox;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

/**
 * TiffinBox's settings: every key under {@code tiffinbox} in application.yaml, bound once, into one typed object.
 *
 * <p>Boot's binder fills it through its only constructor, the record's own. The {@code @param} lines below are not
 * decoration: the configuration processor copies each one into the metadata file an IDE reads, as the description of
 * that key.
 *
 * @param jdbcUrl   the address of TiffinBox's database, an in-memory H2 database
 * @param cooks     how many cooks take orders off the kitchen rail
 * @param days      how many days of orders the kitchen cooks at startup
 * @param port      the port TiffinBox listens on, on 127.0.0.1
 * @param mealTypes the meal types TiffinBox serves
 */
@ConfigurationProperties("tiffinbox")
public record TiffinBoxProperties(String jdbcUrl, int cooks, int days, int port, List<MealType> mealTypes) {
}
