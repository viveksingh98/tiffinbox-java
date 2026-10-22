package probe.web;

import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import org.springframework.stereotype.Component;

/**
 * The course's harness, never TiffinBox's: Tomcat's own word on every session it makes and ends. A session listener bean - Boot
 * registers it with Tomcat - that prints one line through Trace when a session is created and one when a session is destroyed
 * (it timed out, or was invalidated). The session's id is never printed.
 */
@Component
public class Sessions implements HttpSessionListener {

    @Override
    public void sessionCreated(HttpSessionEvent e) {
        Trace.log("Sessions        a session was created");
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent e) {
        Trace.log("Sessions        a session was destroyed");
    }
}
