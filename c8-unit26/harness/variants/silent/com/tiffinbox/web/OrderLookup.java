package com.tiffinbox.web;

import java.util.List;

/** The harness's variant (unit 26, silent): a fragment method whose NAME also parses as a derived query, findByCustomer. */
public interface OrderLookup {

    List<OrderDocument> findByCustomer(String customer);
}
