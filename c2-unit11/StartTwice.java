void main() throws InterruptedException {
    Thread cook = Thread.ofPlatform().name("cook").unstarted(() -> IO.println("one order plated"));
    cook.start();
    cook.join();
    IO.println("state now: " + cook.getState());
    cook.start();
}
