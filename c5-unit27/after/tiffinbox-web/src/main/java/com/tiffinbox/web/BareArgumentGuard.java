package com.tiffinbox.web;

import org.springframework.boot.DefaultApplicationArguments;
import org.springframework.boot.ExitCodeGenerator;
import org.springframework.boot.context.event.ApplicationEnvironmentPreparedEvent;
import org.springframework.context.ApplicationListener;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Course 5: TiffinBox refuses a command-line argument it cannot read. Boot turns "--name=value" into a property and hands
 * every other argument - a bare one - to the application's runners, where nothing in TiffinBox reads it: "java -jar ...
 * 18431", the run command of Courses 2 to 4, started TiffinBox on another port without a word, and a -D option typed after
 * the jar was dropped the same way. This listener runs at the first hook Boot offers once the arguments are parsed - the
 * environment is prepared, the banner not printed, no container, no port - reads the bare arguments with Boot's own
 * DefaultApplicationArguments, and throws on the first start that has one. The exception's exit code is 2;
 * BareArgumentAnalyzer turns it into Boot's two sentences.
 *
 * <p>The sentences never quote an argument they cannot classify: a value typed after a space ("--tiffinbox.shutdown-token
 * VALUE") is a bare argument too, and it may be a secret. Only a bare number of one to five digits - a port, typed the old
 * way - is printed; a -D option, and anything else, is named by its position.
 *
 * <p>Boot reads it from META-INF/spring.factories: a listener for this event must be known before the container exists.
 */
class BareArgumentGuard implements ApplicationListener<ApplicationEnvironmentPreparedEvent> {

    @Override
    public void onApplicationEvent(ApplicationEnvironmentPreparedEvent event) {
        List<String> bare = new DefaultApplicationArguments(event.getArgs()).getNonOptionArgs();
        if (!bare.isEmpty()) {
            throw new BareArguments(event.getArgs());
        }
    }

    /** The refusal: what Boot's failure analysis prints, built from the arguments' positions and shapes, and exit code 2. */
    static final class BareArguments extends RuntimeException implements ExitCodeGenerator {

        private final String description;
        private final String action;

        BareArguments(String[] args) {
            super("TiffinBox reads no bare arguments");
            List<String> found = new ArrayList<>();
            Set<String> actions = new LinkedHashSet<>();
            boolean options = true;                          // Spring's parser: a lone "--" ends the options
            for (int i = 0; i < args.length; i++) {
                String a = args[i], at = "argument " + (i + 1) + " of " + args.length;
                if (options && a.startsWith("--")) {
                    options = !a.equals("--");
                    continue;                                // an option: Boot made it a property
                }
                if (a.matches("[0-9]{1,5}")) {
                    found.add(at + " is " + a);
                    actions.add("To set the port, give it as an option: --tiffinbox.port=" + a + ".");
                } else if (a.startsWith("-D")) {
                    found.add(at + " starts with -D (not shown)");
                    actions.add("Java's -D options go before -jar; after it, give a setting as --name=value.");
                } else {
                    found.add(at + " (not shown)");
                    actions.add("Give a setting as --name=value, in one argument.");
                }
            }
            this.description = "TiffinBox reads no bare arguments: " + String.join("; ", found) + ".";
            this.action = String.join(" ", actions);
        }

        String description() {
            return description;
        }

        String action() {
            return action;
        }

        @Override
        public int getExitCode() {
            return 2;
        }
    }
}
