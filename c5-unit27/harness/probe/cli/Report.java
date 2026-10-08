package probe.cli;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;

import java.util.TreeSet;

/**
 * The harness's runner (the course's, never TiffinBox's: outside com.tiffinbox), joined by --spring.main.sources=probe.cli.Report.
 * Boot calls it after the context is refreshed and hands it the start's arguments, parsed: it prints what it got - the option
 * names (sorted), the non-option arguments, the values of the option tiffinbox.days, and how many arguments the start had. With
 * the option probe.exit=N it then ends the start the way Boot's own API does: SpringApplication.exit closes the context and
 * returns the code its generator gives, and the JVM exits with it.
 */
public class Report implements ApplicationRunner {

    private final ConfigurableApplicationContext context;

    public Report(ConfigurableApplicationContext context) {
        this.context = context;
    }

    @Override
    public void run(ApplicationArguments args) {
        System.out.println("harness: option names " + new TreeSet<>(args.getOptionNames()) + " · non-option arguments "
                + args.getNonOptionArgs() + " · tiffinbox.days " + args.getOptionValues("tiffinbox.days")
                + " · source arguments " + args.getSourceArgs().length);
        if (args.containsOption("probe.exit")) {
            int code = Integer.parseInt(args.getOptionValues("probe.exit").get(0));
            int returned = SpringApplication.exit(context, () -> code);
            System.out.println("harness: SpringApplication.exit returned " + returned);
            System.exit(returned);
        }
    }
}
