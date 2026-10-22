package probe.web;

/** The course's harness, never TiffinBox's: the one exception type ProbeAdvice has a handler for. */
public class ProbeOops extends RuntimeException {

    public ProbeOops(String message) {
        super(message);
    }
}
