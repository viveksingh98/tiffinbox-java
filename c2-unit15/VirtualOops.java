void main() {
    Thread cook = Thread.ofVirtual().name("cook-1").unstarted(() -> IO.println("plated"));
    IO.println("isDaemon: " + cook.isDaemon());

    cook.setDaemon(false);        // the "obvious fix" — make main wait for it
}
