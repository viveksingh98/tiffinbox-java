void main() throws InterruptedException {
    Runnable boil = () -> {
        while (true) {
            try { Thread.sleep(100); } catch (InterruptedException e) { return; }
        }
    };
    Thread kettle = Thread.ofPlatform().name("kettle")
            .daemon(true).unstarted(boil);
    kettle.start();
    Thread.sleep(50);
    IO.println("kettle daemon? " + kettle.isDaemon());
    IO.println("main is done; the JVM does not wait for a daemon");
}
