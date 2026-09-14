package com.tiffinbox.api;

import java.net.URI;
import java.net.http.HttpRequest;

public final class Receipt {
    private Receipt() { }

    public static HttpRequest requestFor(Customer c) {
        return HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:8080/receipt/" + c.name()))
                .GET()
                .build();
    }
}
