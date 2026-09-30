package com.tiffinbox.harness;

import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;

import java.util.Arrays;
import java.util.List;

/**
 * Who answers a key, and what composed the answer. {@code Stack <key> <the arguments TiffinBox's main gets>}.
 *
 * <p>First, before anything starts (so a failed start shows it too), which {@code application.yaml} and
 * {@code application-audit.yaml} the class path gives, and whether the working folder holds the file
 * {@code application.yaml} imports. Then it runs TiffinBox's own main (see {@link Run}) and prints:
 * <ul>
 *   <li>the profiles the Environment holds as active, as Boot resolved them;</li>
 *   <li>how many property sources the Environment held when the context was prepared - BEFORE refresh, the step in
 *       which the container creates the beans - whether one of them came from {@code application-audit.yaml}, and
 *       whether the list after refresh is the same;</li>
 *   <li>the key's stack: the WINNER, the source it came from, and every source in order with what it holds for the key
 *       and Boot's {@code Origin};</li>
 *   <li>the bean field {@code tiffinbox.cooks} ends up in.</li>
 * </ul>
 * Then it closes the context, which stops TiffinBox's server.
 */
public final class Stack {

    private static volatile List<String> beforeRefresh = List.of();

    public static void main(String[] args) throws Exception {
        System.out.println(Run.filesLine());
        String key = args[0];
        ConfigurableApplicationContext ctx = Run.tiffinbox(Arrays.copyOfRange(args, 1, args.length),
                prepared -> beforeRefresh = Run.sources(prepared.getEnvironment()).stream().map(p -> p.getName()).toList());
        try {
            ConfigurableEnvironment env = ctx.getEnvironment();
            System.out.println("active profiles: " + Arrays.toString(env.getActiveProfiles()));
            List<String> after = Run.sources(env).stream().map(p -> p.getName()).toList();
            boolean audit = beforeRefresh.stream().anyMatch(n -> n.contains("[application-audit.yaml]"));
            System.out.println("before refresh: " + beforeRefresh.size() + " property sources · one from application-audit.yaml among them: "
                    + audit + " · after refresh: " + after.size() + ", the same list in the same order: " + after.equals(beforeRefresh));
            for (String line : Run.stack(env, key)) {
                System.out.println(line);
            }
            System.out.println(Run.cooks(ctx));
        } finally {
            ctx.close();
        }
    }
}
