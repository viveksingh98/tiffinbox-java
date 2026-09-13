// Four facts a virtual thread will not negotiate.
void main() throws Exception {
    Thread named = Thread.ofVirtual().name("cook-1")
        .start(() -> IO.println("toString while running: " + Thread.currentThread()));
    named.join();

    Thread probe = Thread.ofVirtual().unstarted(() -> { });
    IO.println("isVirtual:              " + probe.isVirtual());
    IO.println("isDaemon:               " + probe.isDaemon());
    IO.println("getPriority():          " + probe.getPriority());
    probe.setPriority(9);
    IO.println("after setPriority(9):   " + probe.getPriority());
    IO.println("default name:           \"" + probe.getName() + "\"");
}
