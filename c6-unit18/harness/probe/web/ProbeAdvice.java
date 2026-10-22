package probe.web;

import org.springframework.core.MethodParameter;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

/**
 * The course's harness, never TiffinBox's: an advice two ways. Its @ExceptionHandler answers a ProbeOops with a 409 problem detail that
 * names it ("handler": "ProbeAdvice"). As a response-body advice (ResponseBodyAdvice) Spring MVC hands it every body a message converter
 * is about to write, just before it writes it: it prints the path and the body's type, and changes nothing.
 */
@RestControllerAdvice
public class ProbeAdvice implements ResponseBodyAdvice<Object> {

    @ExceptionHandler(ProbeOops.class)
    ProblemDetail oops(ProbeOops e) {
        Trace.log("ProbeAdvice     @ExceptionHandler(ProbeOops): " + e.getMessage());
        ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, e.getMessage());
        p.setProperty("handler", "ProbeAdvice");
        return p;
    }

    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
        return true;
    }

    @Override
    public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType contentType, Class<? extends HttpMessageConverter<?>> converterType,
                                  ServerHttpRequest request, ServerHttpResponse response) {
        Trace.log("ProbeAdvice     beforeBodyWrite " + request.getURI().getPath() + " body " + (body == null ? "none" : body.getClass().getSimpleName()));
        return body;
    }
}
