package com.tiffinbox.web;

/**
 * Course 6: a name nobody has. GET /customers/{name} throws it, and TiffinBoxErrors - the controller advice beside it - answers
 * it: 404 Not Found, and a body that names the customer. It holds the name it was asked for; its message says it.
 *
 * <p>Course 9, unit 24: the old GET /customers/{name} is retired - it answers 410 and throws nothing; GET /api/v1/customers/{name}
 * (CustomerReads) is the route that throws it now.
 */
final class CustomerNotFound extends RuntimeException {

    private final String name;

    CustomerNotFound(String name) {
        super("no customer named " + name);
        this.name = name;
    }

    String name() {
        return name;
    }
}
