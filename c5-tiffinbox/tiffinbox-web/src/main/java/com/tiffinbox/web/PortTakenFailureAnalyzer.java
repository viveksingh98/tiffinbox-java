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
        String where = environment.getProperty("tiffinbox.address") + ":" + environment.getProperty("tiffinbox.port");
        return new FailureAnalysis("TiffinBox could not listen on " + where + ": something else already listens there.",
                "Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.", cause);
    }
}
