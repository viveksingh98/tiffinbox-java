package com.tiffinbox.web;

import com.tiffinbox.OrderEntityRepository;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.MediaTypes;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.web.ErrorResponseException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.lang.reflect.Method;
import java.net.URI;
import java.util.Collections;
import java.util.List;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

/**
 * Course 9, unit 16: one order, GET /api/v1/orders/{id}, as HAL - the order's five members (the order list's OrderView, read through
 * OrderEntityRepository.findById) and, under _links, two links: self, the order's own address, and customer, the address of the
 * customer the order names (GET /api/v1/customers/{name}). Spring HATEOAS writes it (its EntityModel, served as application/hal+json).
 * The hrefs carry the request's own host: the links are built from the request this route answers, never typed.
 *
 * <p>Not final, because self is built by methodOn(OrderResources.class): methodOn makes a CGLIB proxy - a subclass - of the class it is
 * given, records the call made on it, and reads the route off the method called. A final class cannot be subclassed, so methodOn fails on
 * CustomerReads (../c9-unit16, final); the customer link is built by the Method form, linkTo(class, Method, arguments), which makes no
 * proxy, and CustomerReads stays final.
 *
 * <p>It refuses what it does not know, as the order list does: an id no order has (a four oh four, order-unknown, the detail naming the
 * id); any query parameter (a four hundred, parameter-unknown: this route reads none). An id that is not a number is Framework's own four
 * hundred, before this route runs: it carries no type of TiffinBox's.
 *
 * <p>What it does NOT do: it is not the list - OrderPages is the list and stays final, and its next stays a cursor (a next link on the
 * list would be a named change to the list's answer, not made here); no write; it is not an access control - who may read whose order is
 * Course 10's, The Threat Model First; no forwarded-header setting - Boot's default, so a proxy's X-Forwarded-Host is not read.
 */
@RestController
class OrderResources {

    private static final String TYPE = "tag:tiffinbox.example,2026:";

    /**
     * CustomerReads.one, looked up once by name: the Method form needs the Method, because methodOn(CustomerReads.class) cannot make its
     * proxy (Could not generate CGLIB subclass - CustomerReads is final).
     */
    private static final Method CUSTOMER_ONE;
    static {
        try {
            CUSTOMER_ONE = CustomerReads.class.getDeclaredMethod("one", String.class);
        } catch (NoSuchMethodException e) {
            throw new IllegalStateException(e);
        }
    }

    private final OrderEntityRepository orders;

    OrderResources(OrderEntityRepository orders) {
        this.orders = orders;
    }

    @ApiResponse(responseCode = "200", description = "OK - the order, and its self and customer links under _links (HAL)")
    @ApiResponse(responseCode = "400", description = "A query parameter (this route reads none)",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @ApiResponse(responseCode = "404", description = "No order has this id",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    // the two types the route answers in, named so the served document lists them (a client that asks for either, or for anything, gets HAL)
    @GetMapping(value = "/api/v1/orders/{id}", produces = {MediaTypes.HAL_JSON_VALUE, MediaType.APPLICATION_JSON_VALUE})
    EntityModel<OrderPages.OrderView> orderResource(@PathVariable Long id, HttpServletRequest request) {
        if (request != null) {
            List<String> unknown = Collections.list(request.getParameterNames());
            if (!unknown.isEmpty()) {
                throw refusal(HttpStatus.BAD_REQUEST, "parameter-unknown", "Unknown parameter", "unknown parameter " + unknown + "; this route reads none");
            }
        }
        OrderPages.OrderView order = orders.findById(id).map(OrderPages.OrderView::of)
                .orElseThrow(() -> refusal(HttpStatus.NOT_FOUND, "order-unknown", "Order not found", "no order with id " + id));
        return EntityModel.of(order,
                linkTo(methodOn(OrderResources.class).orderResource(id, null)).withSelfRel(),
                linkTo(CustomerReads.class, CUSTOMER_ONE, order.customer()).withRel("customer"));
    }

    private static ErrorResponseException refusal(HttpStatus status, String type, String title, String detail) {
        ProblemDetail p = ProblemDetail.forStatusAndDetail(status, detail);
        p.setType(URI.create(TYPE + type));
        p.setTitle(title);
        return new ErrorResponseException(status, p, null);
    }
}
