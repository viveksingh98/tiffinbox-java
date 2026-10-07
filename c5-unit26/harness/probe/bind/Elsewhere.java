package probe.bind;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import org.springframework.beans.factory.annotation.Value;

/**
 * The course's harness, never TiffinBox's: joined with --spring.main.sources=probe.bind.Elsewhere. A bean that is not
 * TiffinBoxServer and opens a port of its own when it is created - 127.0.0.1 and the port probe.bind.port names. On a port
 * something else holds, its bind throws the same java.net.BindException, "Address already in use", as TiffinBox's would - from
 * its own frames, not TiffinBoxServer's. A failure analyzer for TiffinBox's port must tell the two apart.
 */
public class Elsewhere {

    @Value("${probe.bind.port}")
    private int port;

    private ServerSocket socket;

    @PostConstruct
    void open() throws IOException {
        socket = new ServerSocket();
        socket.bind(new InetSocketAddress("127.0.0.1", port));
    }

    @PreDestroy
    void close() throws IOException {
        if (socket != null) {
            socket.close();
        }
    }
}
