package com.tiffinbox.aot;

import com.tiffinbox.Customer;

import java.util.List;

/** What a formatter does. Both implementations are found by name, at run time, never by import. */
public interface Formatter {
    String render(List<Customer> roster);
}
