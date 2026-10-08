package probe.cli;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.ExitCodeGenerator;

/**
 * The harness's late guard (the course's, never TiffinBox's), joined by --spring.main.sources=probe.cli.LateGuard: the same
 * check as TiffinBox's BareArgumentGuard, written as a runner. Boot calls runners after the context is refreshed - after
 * TiffinBox's server opened its port - so its refusal (exit code 2, through ExitCodeGenerator) comes after the port was open.
 * It names no argument.
 */
public class LateGuard implements ApplicationRunner {

    @Override
    public void run(ApplicationArguments args) {
        if (!args.getNonOptionArgs().isEmpty()) {
            throw new Refused(args.getNonOptionArgs().size());
        }
    }

    static final class Refused extends RuntimeException implements ExitCodeGenerator {
        Refused(int n) {
            super("a runner refused " + n + " bare argument(s)");
        }

        @Override
        public int getExitCode() {
            return 2;
        }
    }
}
