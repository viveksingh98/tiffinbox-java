void main() throws InterruptedException {
    Runnable plate = () -> IO.println("plating on: " + Thread.currentThread().getName());

    Thread cook1 = Thread.ofPlatform().name("cook-1").unstarted(plate);
    cook1.run();
    IO.println("after run():   alive=" + cook1.isAlive() + " state=" + cook1.getState());

    Thread cook2 = Thread.ofPlatform().name("cook-2").unstarted(plate);
    cook2.start();
    cook2.join();
    IO.println("after start(): alive=" + cook2.isAlive() + " state=" + cook2.getState());
}
