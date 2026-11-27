// THE PROBE'S COPY (Course 9 S4 probe): Resilience4j's core Retry, no Spring - the preview's form. Never shipped.
import io.github.resilience4j.retry.Retry;
import io.github.resilience4j.retry.RetryConfig;
import java.util.concurrent.atomic.AtomicInteger;
public class R4Core { public static void main(String[] a) {
  AtomicInteger n = new AtomicInteger();
  Retry retry = Retry.of("pay", RetryConfig.custom().maxAttempts(3).waitDuration(java.time.Duration.ofMillis(10)).build());
  retry.getEventPublisher().onRetry(e -> System.out.println("R4CORE event " + e.getEventType() + " attempt " + e.getNumberOfRetryAttempts()));
  try { Retry.decorateSupplier(retry, () -> { System.out.println("R4CORE call " + n.incrementAndGet()); throw new IllegalStateException("the reply was lost (put in)"); }).get(); }
  catch (Exception e) { System.out.println("R4CORE after " + n.get() + " calls -> " + e.getClass().getName() + ": " + e.getMessage()); }
  System.out.println("R4CORE jar " + Retry.class.getProtectionDomain().getCodeSource().getLocation().getPath().replaceAll(".*/", ""));
} }
