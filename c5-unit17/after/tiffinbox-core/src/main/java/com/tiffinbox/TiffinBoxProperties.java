package com.tiffinbox;

import jakarta.validation.constraints.AssertTrue;
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
 * <p>{@code shutdownToken} is a secret, and it is never committed: it comes from a config tree (application.yaml
 * imports {@code optional:configtree:./secrets/} - the file {@code secrets/tiffinbox/shutdown-token}) or from wherever
 * the operator puts it. A record's own {@code toString()} prints every component, this one included - and a settings
 * object is the first thing anyone logs - so this record writes its own {@code toString()}: every component, and
 * {@code [not shown]} in the token's place. The token's length rule is a yes-or-no method, not a constraint on the token
 * itself: a failure report prints the value of the property that broke a rule, so a rule on the token would print the
 * token.
 *
 * @param jdbcUrl   the address of TiffinBox's database, an in-memory H2 database
 * @param cooks     how many cooks take orders off the kitchen rail
 * @param days      how many days of orders the kitchen cooks at startup
 * @param port      the port TiffinBox listens on
 * @param address   the address it listens on: 127.0.0.1, this computer only, unless a setting says otherwise - a
 *                  container sets 0.0.0.0, every interface of the container, so a port Docker publishes can reach it
 * @param mealTypes the meal types TiffinBox serves
 * @param shutdownToken the secret POST /shutdown asks for, in its X-Shutdown-Token header: 16 characters or more
 */
@Validated
@ConfigurationProperties("tiffinbox")
public record TiffinBoxProperties(@NotBlank String jdbcUrl, @NotNull @Min(1) Integer cooks, @NotNull @Min(1) Integer days,
                                  @NotNull @Min(1) Integer port, @NotBlank String address,
                                  @NotEmpty List<MealType> mealTypes, @NotBlank String shutdownToken) {

    /** The token's length rule. A failure report prints what this returns - false - and never the token. */
    @AssertTrue(message = "tiffinbox.shutdown-token must be 16 characters or more")
    public boolean isShutdownTokenLongEnough() {
        return shutdownToken == null || shutdownToken.isBlank() || shutdownToken.length() >= 16;
    }

    /** The record's own format, component by component, with the token's value replaced: logging the record is safe. */
    @Override
    public String toString() {
        return "TiffinBoxProperties[jdbcUrl=" + jdbcUrl + ", cooks=" + cooks + ", days=" + days + ", port=" + port
                + ", address=" + address + ", mealTypes=" + mealTypes
                + ", shutdownToken=" + (shutdownToken == null ? "null" : "[not shown]") + "]";
    }
}
