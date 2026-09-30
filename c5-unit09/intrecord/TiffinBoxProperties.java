package com.tiffinbox;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import java.util.List;

/**
 * TiffinBox's settings: every key under {@code tiffinbox} in application.yaml, bound once, into one typed object.
 *
 * <p>Boot's binder fills it through its only constructor, the record's own. The {@code @param} lines below are not
 * decoration: the configuration processor copies each one into the metadata file an IDE reads, as the description of
 * that key.
 *
 * <p>{@code @Validated} asks the binder to check the constraints below. A value that breaks one stops the start, before
 * TiffinBox's port opens, with a report: the property, its value, where it came from, and the rule it broke. The three
 * numbers are {@code Integer}, not {@code int}: a key nobody wrote is then {@code null}, which {@code @NotNull} reports
 * as missing - an {@code int} would be a zero that nobody wrote.
 *
 * @param jdbcUrl   the address of TiffinBox's database, an in-memory H2 database
 * @param cooks     how many cooks take orders off the kitchen rail
 * @param days      how many days of orders the kitchen cooks at startup
 * @param port      the port TiffinBox listens on, on 127.0.0.1
 * @param mealTypes the meal types TiffinBox serves
 */
@Validated
@ConfigurationProperties("tiffinbox")
public record TiffinBoxProperties(@NotBlank String jdbcUrl, @Min(1) int cooks, @Min(1) int days, @Min(1) int port,
                                  @NotEmpty List<MealType> mealTypes) {
}
