import java.net.Socket;

void main() throws Exception {
    IO.println("dialling the order line on 8123 ...");
    Socket socket = new Socket("localhost", 8123);   // line 5
    IO.println("connected — you will never see this");
    socket.close();
}
