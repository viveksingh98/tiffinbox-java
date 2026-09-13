import java.util.ArrayList;

void main() {
    var orders = new ArrayList<byte[]>();
    int mb = 0;
    while (true) {
        orders.add(new byte[1024 * 1024]);
        mb++;
        IO.println("holding " + mb + " MB");
    }
}
