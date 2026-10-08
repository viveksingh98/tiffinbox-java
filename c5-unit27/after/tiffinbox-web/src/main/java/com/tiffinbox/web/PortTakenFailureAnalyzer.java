package com.tiffinbox.web;

import org.springframework.boot.diagnostics.AbstractFailureAnalyzer;
import org.springframework.boot.diagnostics.FailureAnalysis;
import org.springframework.core.env.Environment;

import java.net.BindException;

/**
 * Course 5: TiffinBox's own start failure, explained to Boot. When something else already listens on TiffinBox's port,
 * TiffinBoxServer's start throws java.net.BindException and the start stops under forty stack frames: Boot's own port
 * analyzer serves Boot's own web servers, and TiffinBox's is the JDK's. This analyzer turns that BindException into two
 * sentences - where TiffinBox tried to listen, and what to do - read from the Environment Boot hands its constructor. Only
 * the address and the port: never another setting.
 *
 * <p>Only that failure: the port in use ("Address already in use"), and the bind the one TiffinBoxServer's start makes (that
 * method on the exception's stack - not just TiffinBoxServer's main, which is under every failure of a start). Any other
 * BindException - an address this machine does not have, another bean's port - is not TiffinBox's port taken: the analyzer
 * returns null, and Boot prints the trace as before.
 *
 * <p>Boot reads it from META-INF/spring.factories - a file of names, read by a loader when the start fails - never from the
 * context. Declared as a bean instead, it would change nothing.
 */
class PortTakenFailureAnalyzer extends AbstractFailureAnalyzer<BindException> {

    private final Environment environment;

    PortTakenFailureAnalyzer(Environment environment) {
        this.environment = environment;
    }

    @Override
    protected FailureAnalysis analyze(Throwable rootFailure, BindException cause) {
        if (!"Address already in use".equals(cause.getMessage()) || !thrownIn(TiffinBoxServer.class, "start", cause)) {
            return null;                             // not TiffinBox's port taken: Boot keeps the trace
        }
        String where = environment.getProperty("tiffinbox.address") + ":" + environment.getProperty("tiffinbox.port");
        return new FailureAnalysis("TiffinBox could not listen on " + where + ": something else already listens there.",
                "Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.", cause);
    }

    /** Whether the method is on the exception's stack: the bind that failed was the one that method makes. */
    private static boolean thrownIn(Class<?> type, String method, Throwable failure) {
        for (StackTraceElement frame : failure.getStackTrace()) {
            if (frame.getClassName().equals(type.getName()) && frame.getMethodName().equals(method)) {
                return true;
            }
        }
        return false;
    }
}
