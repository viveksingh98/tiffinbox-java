package com.tiffinbox.web;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.handler.SimpleUrlHandlerMapping;

/**
 * Course 6: TiffinBox's routes, handed to Spring MVC. A handler mapping answers one question for the DispatcherServlet -
 * which handler takes this request? - and SimpleUrlHandlerMapping is Spring's own kind that answers it from a table of
 * paths: here one handler per path, {@link TiffinBoxServer#handlers()}. Spring's HttpRequestHandlerAdapter calls the
 * handler. Declaring and scanning the routes (Route, scanRoutes()) stays TiffinBox's until Course 6's request-mapping lesson.
 */
@Configuration(proxyBeanMethods = false)
class RouteMapping {

    @Bean
    SimpleUrlHandlerMapping tiffinBoxRoutes(TiffinBoxServer server) {
        return new SimpleUrlHandlerMapping(server.handlers(), 0);
    }
}
