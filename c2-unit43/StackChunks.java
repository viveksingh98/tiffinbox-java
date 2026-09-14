// StackChunks.java — what is jdk.internal.vm.StackChunk, and who allocates it?
// Same work, same JVM, two executors. Run each under its own flight recording.
//   java -XX:StartFlightRecording=filename=v.jfr,settings=profile StackChunks.java virtual
//   java -XX:StartFlightRecording=filename=p.jfr,settings=profile StackChunks.java platform
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;

void main(String[] args) throws Exception {
    boolean virtual = args.length == 0 || args[0].equals("virtual");
    int tasks = 40_000;
    var done = new AtomicLong();
    ExecutorService pool = virtual
            ? Executors.newVirtualThreadPerTaskExecutor()
            : Executors.newFixedThreadPool(8);
    try (pool) {
        for (int i = 0; i < tasks; i++) {
            pool.submit(() -> {
                try { TimeUnit.MILLISECONDS.sleep(1); } catch (InterruptedException e) { return; }
                done.incrementAndGet();
            });
        }
    }
    IO.println("executor: " + (virtual ? "virtual" : "platform"));
    IO.println("tasks:    " + done.get());
}
