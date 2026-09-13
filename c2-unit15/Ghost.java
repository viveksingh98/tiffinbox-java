// Three cooks started, nobody joined. Every virtual thread is a daemon thread.
void main() {
    for (int i = 1; i <= 3; i++) {
        int n = i;
        Thread.ofVirtual().name("cook-" + n).start(() -> {
            try { Thread.sleep(300); } catch (InterruptedException e) { return; }
            IO.println("cook-" + n + " plated an order");      // never reached
        });
    }
    IO.println("main is done. three cooks were started.");
}
