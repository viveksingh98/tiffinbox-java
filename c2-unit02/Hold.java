import java.util.ArrayList;

void main() throws InterruptedException {
    var kept = new ArrayList<byte[]>();
    for (int i = 0; i < 20; i++) kept.add(new byte[1024 * 1024]);
    IO.println("holding 20 MB — inspect me with jcmd, then press Ctrl-C");
    Thread.sleep(600_000);
}
