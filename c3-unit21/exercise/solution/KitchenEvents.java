package com.tiffinbox.kitchen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import static net.logstash.logback.argument.StructuredArguments.kv;

/**
 * One service, one run, one set of events - written twice.
 *
 * <p>The logback.xml beside this file attaches TWO appenders to the root: a pattern layout
 * writing target/logs/kitchen.log and a JSON encoder writing target/logs/kitchen.json.
 * Every event below reaches both. That is deliberate and it is the whole design of this
 * unit: if the two forms came from two runs, any difference between the answers could be
 * blamed on the runs rather than on the encoding.
 *
 * <p>THE ANSWER. The two "accepted" calls now use StructuredArguments.kv, which does two
 * things at once: it renders "customer=Arun" into the human-readable message AND adds
 * "customer":"Arun" as a top-level key in the JSON. One argument, both audiences.
 *
 * <p>The MDC would also have worked and is the right tool when the value belongs to every
 * line of a request. kv is the right tool when the value belongs to ONE event, which is
 * what a customer name on an "accepted" line is.
 */
public final class KitchenEvents {

    private static final Logger log = LoggerFactory.getLogger("kitchen");

    public static void main(String[] args) {
        MDC.put("orderId", "A-4417");
        log.info("accepted for {}", kv("customer", "Arun"));
        // (1) THE MESSAGE MENTIONS ANOTHER ORDER. grep cannot tell a field from a word.
        log.warn("short on rice, splitting the rest of order B-9082 to tomorrow");
        MDC.remove("orderId");

        MDC.put("orderId", "B-9082");
        log.info("accepted for {}", kv("customer", "Bela"));
        // (2) THE MESSAGE CONTAINS THE TEXT LAYOUT'S OWN DELIMITER.
        log.warn("kitchen is behind - 12 slips waiting");
        try {
            throw new IllegalStateException("rail jammed");
        } catch (RuntimeException e) {
            // (3) A STACK TRACE. One event; in the text log it is many lines.
            log.error("could not cook", e);
        }
        MDC.remove("orderId");

        // (4) NO ORDER ID AT ALL. The JSON key is absent, not empty.
        log.info("end of service");
    }
}
