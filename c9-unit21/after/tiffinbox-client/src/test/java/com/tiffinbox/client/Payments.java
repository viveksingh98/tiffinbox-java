package com.tiffinbox.client;

import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;
import org.springframework.web.service.annotation.PostExchange;

/**
 * Course 9, unit 21: TiffinBox as the caller - a hand-written HTTP interface for a payment party, in Course 6's payments shape
 * (@HttpExchange("/payments"), a POST of a charge, the slow path) plus ONE parameter this unit adds: the Idempotency-Key header,
 * which is the caller's argument and is sent on every attempt the caller makes.
 *
 * <p>What it does NOT do: it is not the generated client (ApiApi.add1 has no key parameter); it honours no key itself - whether a
 * party answers a repeated key with its first answer is that party's; it sets no timeout (the RestClient handed to it decides);
 * it is test scope, so no main jar carries it.
 */
@HttpExchange("/payments")
public interface Payments {

    /** Course 9, unit 21: the header's name - the test reads it from here, so this file is the only one that spells it. */
    String KEY_HEADER = "Idempotency-Key";

    /** Course 9, unit 21: one charge, the key in its header. The party answers 201 and the payment it made. */
    @PostExchange
    Payment pay(@RequestHeader("Idempotency-Key") String key, @RequestBody Charge charge);

    /** Course 6's slow path: a later call a caller may make in the same method. */
    @GetExchange("/slow")
    String slow();

    /** What the caller asks for. */
    record Charge(String customer, int amount) {
    }

    /** What the party answers: its own id for the payment it made. */
    record Payment(String id, String status, String customer, int amount) {
    }
}
