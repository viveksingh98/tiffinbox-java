static final Object counterLock = new Object();

void main() throws InterruptedException {
    IO.println("waiting for the next order...");
    counterLock.wait();                        // no monitor held
    IO.println("this line is never reached");
}
