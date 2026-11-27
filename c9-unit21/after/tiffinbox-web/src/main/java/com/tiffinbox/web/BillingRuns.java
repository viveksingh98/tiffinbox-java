package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import io.swagger.v3.oas.annotations.headers.Header;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.ErrorResponseException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Course 9, unit 17: a billing run - POST /api/v1/billing-runs bills every customer, and GET /api/v1/billing-runs/{id} is its status
 * resource. The POST answers at once, before the bills are made: a two oh two (Accepted) whose Location is the run's own address,
 * built from the request this route answers (so it carries the request's host, never a typed one), and whose Retry-After header
 * says when to come back. The run itself goes on, on a virtual thread of its own: it reads the customers through
 * CustomerRepository.findAll and bills each one with Customer.monthlyBill. The status resource answers the run's state - RUNNING,
 * then SUCCEEDED with the four bills, keyed by the customer's name (or FAILED, if the read throws) - and sends Retry-After while the
 * run is not finished and never once it is.
 *
 * <p>The store is a map in this JVM (a ConcurrentHashMap, run id to run). It is not durable: a restart empties it, and the old
 * address then answers a four oh four. Durable jobs are Spring Batch and Scheduling's and Messaging and Integration's, not built here.
 * No eviction: a long-lived JVM keeps every run, and its bills, until it stops.
 *
 * <p>The pause between two customers is the harness's, off by default: the setting tiffinbox.billing-runs.harness-pause-ms, never in
 * application.yaml, is given on a run's command line by the receipts and the exercise so that a client can see a run that is not
 * finished. Without it a run bills the four customers as fast as the read allows.
 *
 * <p>It refuses what it does not know, as the order resource does: an id no run has (a four oh four, billing-run-unknown, the detail
 * naming the id); any query parameter on either route (a four hundred, parameter-unknown: these routes read none).
 *
 * <p>What it does NOT do: no cancel and no list of runs; no Idempotency-Key handling - the route is not in IdempotencyKeyFilter's table,
 * so two POSTs start two runs, with a key or without one; it is not an access control - who may start or read a run is Course 10's,
 * The Threat Model First.
 */
@RestController
final class BillingRuns {

    private static final String TYPE = "tag:tiffinbox.example,2026:";

    /** The value of Retry-After, in seconds, sent while a run is not finished. */
    static final String COME_BACK = "1";

    /** A run's states. A run is RUNNING from the moment it is accepted; SUCCEEDED and FAILED are terminal. */
    enum State { RUNNING, SUCCEEDED, FAILED }

    /** What the POST and the status resource answer: the run's id, its state, and the bills once it has SUCCEEDED (else absent). */
    @Schema(name = "BillingRun")
    record BillingRunView(String id, State state, @Schema(nullable = true) Map<String, Integer> bills) {
    }

    private static final class Run {
        final String id;
        volatile State state = State.RUNNING;
        volatile Map<String, Integer> bills;

        Run(String id) {
            this.id = id;
        }

        BillingRunView view() {
            State s = state;
            return new BillingRunView(id, s, s == State.SUCCEEDED ? bills : null);
        }
    }

    private final CustomerRepository customers;
    private final long harnessPauseMs;
    private final Map<String, Run> runs = new ConcurrentHashMap<>();

    BillingRuns(CustomerRepository customers, @Value("${tiffinbox.billing-runs.harness-pause-ms:0}") long harnessPauseMs) {
        this.customers = customers;
        this.harnessPauseMs = harnessPauseMs;
    }

    @ApiResponse(responseCode = "202", description = "Accepted - the run is started; Location is its status resource",
            headers = {
                    @Header(name = "Location", description = "The run's status resource", schema = @Schema(type = "string", format = "uri")),
                    @Header(name = "Retry-After", description = "When to come back, sent while the run is not finished",
                            schema = @Schema(type = "string"))},
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = BillingRunView.class)))
    @ApiResponse(responseCode = "400", description = "A query parameter (this route reads none)",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @PostMapping("/api/v1/billing-runs")
    ResponseEntity<BillingRunView> startBillingRun(HttpServletRequest request) {
        refuseParameters(request);
        Run run = new Run(UUID.randomUUID().toString());
        runs.put(run.id, run);
        Thread.ofVirtual().start(() -> bill(run));
        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{id}").buildAndExpand(run.id).toUri();
        BillingRunView view = run.view();
        ResponseEntity.BodyBuilder answer = ResponseEntity.accepted().location(location);
        if (view.state() == State.RUNNING) {
            answer.header(HttpHeaders.RETRY_AFTER, COME_BACK);
        }
        return answer.body(view);
    }

    @ApiResponse(responseCode = "200", description = "OK - the run's state, and its bills once it has succeeded",
            headers = @Header(name = "Retry-After", description = "When to come back, sent only while the run is not finished",
                    schema = @Schema(type = "string")),
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = BillingRunView.class)))
    @ApiResponse(responseCode = "400", description = "A query parameter (this route reads none)",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @ApiResponse(responseCode = "404", description = "No run has this id (in this JVM)",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @GetMapping("/api/v1/billing-runs/{id}")
    ResponseEntity<BillingRunView> billingRun(@PathVariable String id, HttpServletRequest request) {
        refuseParameters(request);
        Run run = runs.get(id);
        if (run == null) {
            throw refusal(HttpStatus.NOT_FOUND, "billing-run-unknown", "Billing run not found", "no billing run with id " + id);
        }
        BillingRunView view = run.view();
        ResponseEntity.BodyBuilder answer = ResponseEntity.ok();
        if (view.state() == State.RUNNING) {
            answer.header(HttpHeaders.RETRY_AFTER, COME_BACK);
        }
        return answer.body(view);
    }

    /** The run itself: every customer, one bill each; the harness's pause, if one was given, before each customer. */
    private void bill(Run run) {
        try {
            Map<String, Integer> bills = new TreeMap<>();
            List<Customer> all = customers.findAll();
            for (Customer c : all) {
                if (harnessPauseMs > 0) {
                    Thread.sleep(harnessPauseMs);
                }
                bills.put(c.name(), c.monthlyBill());
            }
            run.bills = Collections.unmodifiableMap(bills);
            run.state = State.SUCCEEDED;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            run.state = State.FAILED;
        } catch (SQLException | RuntimeException e) {
            run.state = State.FAILED;
        }
    }

    private static void refuseParameters(HttpServletRequest request) {
        List<String> unknown = Collections.list(request.getParameterNames());
        if (!unknown.isEmpty()) {
            throw refusal(HttpStatus.BAD_REQUEST, "parameter-unknown", "Unknown parameter", "unknown parameter " + unknown + "; this route reads none");
        }
    }

    private static ErrorResponseException refusal(HttpStatus status, String type, String title, String detail) {
        ProblemDetail p = ProblemDetail.forStatusAndDetail(status, detail);
        p.setType(URI.create(TYPE + type));
        p.setTitle(title);
        return new ErrorResponseException(status, p, null);
    }
}
