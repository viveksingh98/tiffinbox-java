package com.tiffinbox;

/** Where an order goes. An interface — which is exactly what the JDK's proxy needs. */
public interface Rail {
    String place(String customer);
}
