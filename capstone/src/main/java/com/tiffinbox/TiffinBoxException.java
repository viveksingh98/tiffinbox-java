package com.tiffinbox;

public class TiffinBoxException extends RuntimeException {

    public TiffinBoxException(String message) {
        super(message);
    }

    public TiffinBoxException(String message, Throwable cause) {
        super(message, cause);
    }
}
