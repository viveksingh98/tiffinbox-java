package com.tiffinbox.web;

import com.tiffinbox.TiffinBoxProperties;
import org.springframework.aot.hint.ExecutableMode;
import org.springframework.aot.hint.RuntimeHints;
import org.springframework.aot.hint.RuntimeHintsRegistrar;
import org.springframework.util.ReflectionUtils;

/**
 * The general tool, for a labelled capture only (receipts.sh, capture metadata, E) - never part of the anchor. Spring's
 * ahead-of-time step runs this code while the jar is built, and writes what it registers into reachability-metadata.json:
 * here, the same entry the anchor's @Reflective writes for the token-length rule, Hibernate Validator's call by reflection.
 * receipts.sh copies it into a copy of after/, takes that @Reflective out, and imports this class with
 * {@code @ImportRuntimeHints(ValidatorHints.class)} on that copy's TiffinBoxApp.
 */
public class ValidatorHints implements RuntimeHintsRegistrar {
    @Override
    public void registerHints(RuntimeHints hints, ClassLoader classLoader) {
        hints.reflection().registerMethod(
                ReflectionUtils.findMethod(TiffinBoxProperties.class, "isShutdownTokenLongEnough"), ExecutableMode.INVOKE);
    }
}
