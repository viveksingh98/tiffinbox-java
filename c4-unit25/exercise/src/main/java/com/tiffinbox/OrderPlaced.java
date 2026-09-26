package com.tiffinbox;

/** The event. A plain record - no framework base class, which has been true since Framework 4.2. */
public record OrderPlaced(String customer, int total) { }
