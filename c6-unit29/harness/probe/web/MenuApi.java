package probe.web;

import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;

/** The course's harness: an HTTP interface (Spring's @HttpExchange, org.springframework.web.service.annotation - not the JDK
 *  server's com.sun.net.httpserver.HttpExchange, which the stub uses) for two of the stub's files. names() asks for no version;
 *  meera() asks for 2.0 on its own annotation. The version reaches the wire only through the group's keys. */
@HttpExchange
public interface MenuApi {
    @GetExchange("/ravi.json")
    String ravi();

    @GetExchange(url = "/meera.json", version = "2.0")
    String meera();
}
