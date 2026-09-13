import java.util.concurrent.*;

void main() throws Exception {
    ExecutorService pool = Executors.newFixedThreadPool(2);

    Future<Integer> f = pool.submit(() -> 7200 / Integer.parseInt("0"));
    IO.println("task submitted; main is still alive and nothing was printed");

    try {
        f.get();
    } catch (ExecutionException e) {
        IO.println("caught: " + e);
        IO.println("cause:  " + e.getCause());
    }

    pool.close();
    pool.submit(() -> IO.println("this task never runs"));
}
