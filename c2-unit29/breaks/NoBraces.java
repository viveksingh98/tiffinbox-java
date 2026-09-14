package com.tiffinbox;

import com.fasterxml.jackson.core.type.TypeReference;
import java.util.List;

public final class NoBraces {
    static final TypeReference<List<Customer>> WITHOUT_BRACES = new TypeReference<List<Customer>>();

    public static void main(String[] args) throws Exception {
        List<Customer> cs = Json.MAPPER.readValue(Json.BOOK, WITHOUT_BRACES);
        System.out.println("never reached: " + cs.size());
    }
}
