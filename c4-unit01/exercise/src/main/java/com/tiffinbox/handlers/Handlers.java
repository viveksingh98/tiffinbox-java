package com.tiffinbox.handlers;

/** Asha's four methods. Three wear the label; the fourth is the control. */
public class Handlers {
    @Route(path = "/customers")            public String listCustomers() { return "customers"; }
    @Route(path = "/revenue")              public String revenue()       { return "revenue"; }
    @Route(method = "POST", path = "/orders") public String placeOrder() { return "order accepted"; }
    public String notARoute() { return "not a route"; }
}
