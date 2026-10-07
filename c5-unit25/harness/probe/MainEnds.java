package probe;

/**
 * The course's harness, not TiffinBox's: the JVM's own rule for an exit code, with nothing of Spring in it. Its main thread
 * starts one more thread that is not a daemon (the JVM waits for it, as it waits for TiffinBox's server) and gives itself an
 * uncaught-exception handler that prints nothing. Run with "throw", the main thread then ends with an exception; run with
 * "return", it returns. Nothing is printed either way: only the exit code tells the two apart.
 */
public final class MainEnds {

    public static void main(String[] args) {
        Thread.currentThread().setUncaughtExceptionHandler((thread, e) -> { });
        Thread.ofPlatform().start(() -> {
            try {
                Thread.sleep(300);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        if (args.length > 0 && args[0].equals("throw")) {
            throw new IllegalStateException("the main thread ends here");
        }
    }
}
