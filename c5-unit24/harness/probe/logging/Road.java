package probe.logging;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.spi.LoggerContextListener;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Handler;
import java.util.logging.LogManager;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;

/**
 * The course's harness, never TiffinBox's: joined with --spring.main.sources=probe.logging.Road. When TiffinBox is ready
 * it prints the road one log line takes - java.util.logging's root logger (its handlers and its level, and what its
 * configuration file asked for), Logback's root logger (its appenders and its level) and Logback's listeners - then
 * TiffinBox's own logger as each of the three sees it. From then on, each time Logback's level for "tiffinbox" or for the
 * root logger is set - the loggers endpoint, for one - it prints that view again. Its lines start "harness: " and go to
 * standard output, where Boot's log goes, in the order they happen.
 */
public class Road implements ApplicationListener<ApplicationReadyEvent> {

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        LogManager manager = LogManager.getLogManager();
        java.util.logging.Logger julRoot = manager.getLogger("");
        List<String> handlers = new ArrayList<>();
        for (Handler handler : julRoot.getHandlers()) {
            handlers.add(handler.getClass().getName());
        }
        say("java.util.logging's root logger - its handlers: " + handlers + " · its level: " + julRoot.getLevel());
        say("what java.util.logging's configuration file asked for (LogManager's properties) - handlers: "
                + manager.getProperty("handlers") + " · .level: " + manager.getProperty(".level"));
        LoggerContext logback = (LoggerContext) LoggerFactory.getILoggerFactory();
        Logger root = logback.getLogger(Logger.ROOT_LOGGER_NAME);
        List<String> appenders = new ArrayList<>();
        root.iteratorForAppenders().forEachRemaining(a -> appenders.add(a.getName() + " " + a.getClass().getName()));
        say("Logback's root logger - its appenders: " + appenders + " · its level: " + root.getLevel());
        List<String> listeners = new ArrayList<>();
        for (LoggerContextListener listener : logback.getCopyOfListenerList()) {
            listeners.add(listener.getClass().getName());
        }
        say("Logback's listeners: " + listeners);
        view("at start");
        logback.addListener(new LoggerContextListener() {
            @Override public boolean isResetResistant() { return false; }
            @Override public void onStart(LoggerContext context) { }
            @Override public void onReset(LoggerContext context) { }
            @Override public void onStop(LoggerContext context) { }
            @Override public void onLevelChange(Logger logger, Level level) {
                if (logger.getName().equals("tiffinbox") || logger.getName().equals(Logger.ROOT_LOGGER_NAME)) {
                    view("Logback's " + logger.getName() + " changed");
                }
            }
        });
    }

    /** TiffinBox's logger, three ways: Logback's level, java.util.logging's level, and System.Logger's DEBUG check. */
    private static void view(String when) {
        LoggerContext logback = (LoggerContext) LoggerFactory.getILoggerFactory();
        say(when + " - TiffinBox's logger: Logback's tiffinbox " + logback.getLogger("tiffinbox").getEffectiveLevel()
                + " · java.util.logging's tiffinbox " + java.util.logging.Logger.getLogger("tiffinbox").getLevel()
                + " · System.Logger DEBUG loggable: " + System.getLogger("tiffinbox").isLoggable(System.Logger.Level.DEBUG));
    }

    private static void say(String line) {
        System.out.println("harness: " + line);
    }
}
