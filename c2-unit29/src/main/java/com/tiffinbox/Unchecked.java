package com.tiffinbox;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.List;

/** The wrong way to read a list: List.class instead of a TypeReference. */
public final class Unchecked {

    public static void main(String[] args) throws Exception {
        List<Customer> cs = new ObjectMapper().readValue(Json.BOOK, List.class);
        System.out.println("this line is fine: " + cs.size());
        Customer first = cs.get(0);
        System.out.println("never reached: " + first.monthlyBill());
    }
}
