package com.tiffinbox.legacy;

import java.net.http.HttpClient;
import java.sql.Driver;

public class Legacy {
    public static void main(String[] args) {
        IO.println("client: " + HttpClient.class.getModule().getName());
        IO.println("this class module: " + Legacy.class.getModule().getName());
        IO.println("named module? " + Legacy.class.getModule().isNamed());
        IO.println("driver iface: " + Driver.class.getModule().getName());
    }
}
