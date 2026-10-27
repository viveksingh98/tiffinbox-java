package probe.web;

import java.io.IOException;
import org.springframework.http.HttpRequest;
import org.springframework.http.client.ClientHttpRequestExecution;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.http.client.ClientHttpResponse;

/**
 * The course's harness, never TiffinBox's: an interceptor on a client - code that sees every request the client is about to send,
 * and may change it, before it leaves. This one adds one header, X-Via: template-interceptor, and changes nothing else: the stub's
 * dump shows which requests carried it, so the dump says which client a request came from.
 */
public class Via implements ClientHttpRequestInterceptor {

    @Override
    public ClientHttpResponse intercept(HttpRequest request, byte[] body, ClientHttpRequestExecution execution) throws IOException {
        request.getHeaders().add("X-Via", "template-interceptor");
        return execution.execute(request, body);
    }
}
