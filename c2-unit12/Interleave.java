import java.util.concurrent.Semaphore;

// A baton that forces ONE order, so the log is stable. It is not a fix.
static final Semaphore bRead  = new Semaphore(0);
static final Semaphore aWrite = new Semaphore(0);
static final Semaphore bWrite = new Semaphore(0);

static int ordersTaken = 41;

void main() throws InterruptedException {
    Thread cook1 = new Thread(() -> {
        int local = ordersTaken;
        IO.println("cook-1 reads  ordersTaken = " + local);
        bRead.release();
        aWrite.acquireUninterruptibly();
        ordersTaken = local + 1;
        IO.println("cook-1 writes ordersTaken = " + ordersTaken);
        bWrite.release();
    }, "cook-1");

    Thread cook2 = new Thread(() -> {
        bRead.acquireUninterruptibly();
        int local = ordersTaken;
        IO.println("cook-2 reads  ordersTaken = " + local);
        aWrite.release();
        bWrite.acquireUninterruptibly();
        ordersTaken = local + 1;
        IO.println("cook-2 writes ordersTaken = " + ordersTaken);
    }, "cook-2");

    cook1.start();
    cook2.start();
    cook1.join();
    cook2.join();
    IO.println("two orders taken, counter moved by " + (ordersTaken - 41));
}
