import java.io.*;
import java.net.*;
import static java.nio.charset.StandardCharsets.UTF_8;

void main() throws Exception {
    try (Socket socket = new Socket("localhost", 8123);
         var out = new PrintWriter(new OutputStreamWriter(
                 socket.getOutputStream(), UTF_8), true);
         var in  = new BufferedReader(new InputStreamReader(
                 socket.getInputStream(), UTF_8))) {
        socket.setSoTimeout(1500);   // so the hang ends, not lasts
        out.print("ORDER Ravi 2");   // no newline, and print() does
        out.flush();                 // not auto-flush: we flush it
        IO.println("sent 12 bytes, no newline:  ORDER Ravi 2");
        try {
            IO.println("reply:  " + in.readLine());
        } catch (SocketTimeoutException e) {
            IO.println("after 1500 ms:  " + e);
        }
        out.print("\n");             // the one missing byte
        out.flush();
        IO.println("sent the newline, reply:    " + in.readLine());
        out.println("CLOSE");
        IO.println("CLOSE                       " + in.readLine());
    }
}
