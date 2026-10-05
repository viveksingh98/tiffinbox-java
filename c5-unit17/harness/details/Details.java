package details;

import com.tiffinbox.web.TiffinBoxApp;
import java.sql.Connection;
import java.util.Map;
import javax.sql.DataSource;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.condition.ConditionEvaluationReport;
import org.springframework.boot.jdbc.autoconfigure.JdbcConnectionDetails;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * Starts TiffinBox's own application (TiffinBoxApp, as TiffinBoxServer's main method does) with the arguments it is given,
 * then prints what Boot registered for a database: every JdbcConnectionDetails bean (its name, its class, the URL and the
 * user it holds, and whether it holds a password), every DataSource bean (its name, its class, and the database it
 * connects to), and the condition report's verdict on DataSourceAutoConfiguration and its nested configurations - the
 * outcome, and each condition's message on a line of its own (a nested condition's parts each on their own line). Then it
 * closes the context and exits. It never prints a password. It lives outside com.tiffinbox, so TiffinBox's component scan
 * never finds it.
 */
public class Details {
    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext context = SpringApplication.run(TiffinBoxApp.class, args);
        String[] names = context.getBeanNamesForType(JdbcConnectionDetails.class);
        System.out.println("beans of type JdbcConnectionDetails: " + names.length);
        for (String name : names) {
            JdbcConnectionDetails details = context.getBean(name, JdbcConnectionDetails.class);
            String password = details.getPassword();
            System.out.println("  " + name + " -> " + details.getClass().getName());
            System.out.println("    url=" + details.getJdbcUrl() + " user=" + details.getUsername()
                    + " password=" + (password == null || password.isEmpty() ? "(none)" : "(set, not shown)"));
        }
        String[] sources = context.getBeanNamesForType(DataSource.class);
        System.out.println("beans of type DataSource: " + sources.length);
        for (String name : sources) {
            DataSource source = context.getBean(name, DataSource.class);
            System.out.println("  " + name + " -> " + source.getClass().getName());
            try (Connection connection = source.getConnection()) {
                System.out.println("    connects to: " + connection.getMetaData().getDatabaseProductName() + " "
                        + connection.getMetaData().getURL());
            }
        }
        String prefix = "org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration";
        ConditionEvaluationReport report = ConditionEvaluationReport.get(context.getBeanFactory());
        for (Map.Entry<String, ConditionEvaluationReport.ConditionAndOutcomes> entry
                : report.getConditionAndOutcomesBySource().entrySet()) {
            if (!entry.getKey().startsWith(prefix)) {
                continue;
            }
            System.out.println("the condition report: " + entry.getKey().substring(entry.getKey().lastIndexOf('.') + 1)
                    + " -> " + (entry.getValue().isFullMatch() ? "matched" : "did not match"));
            for (ConditionEvaluationReport.ConditionAndOutcome outcome : entry.getValue()) {
                for (String part : outcome.getOutcome().getMessage().split("; (?=NestedCondition )")) {
                    System.out.println("    " + part);
                }
            }
        }
        context.close();
    }
}
