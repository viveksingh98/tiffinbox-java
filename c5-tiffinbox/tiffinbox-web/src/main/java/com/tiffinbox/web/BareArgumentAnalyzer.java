package com.tiffinbox.web;

import org.springframework.boot.diagnostics.AbstractFailureAnalyzer;
import org.springframework.boot.diagnostics.FailureAnalysis;

/**
 * Course 5: the refusal BareArgumentGuard throws, explained to Boot - its description and its action, in place of the stack
 * trace. Boot runs its failure analysis even when the start fails before any container exists, as this one does; it reads
 * this class from META-INF/spring.factories, like PortTakenFailureAnalyzer.
 */
class BareArgumentAnalyzer extends AbstractFailureAnalyzer<BareArgumentGuard.BareArguments> {

    @Override
    protected FailureAnalysis analyze(Throwable rootFailure, BareArgumentGuard.BareArguments cause) {
        return new FailureAnalysis(cause.description(), cause.action(), cause);
    }
}
