void main() throws InterruptedException {
    var kept = new byte[20][];
    for (int i = 0; i < 20; i++) kept[i] = new byte[1024 * 1024];
    IO.println("holding " + kept.length + " MB — inspect me with jcmd");
    Thread.sleep(60_000);
}
