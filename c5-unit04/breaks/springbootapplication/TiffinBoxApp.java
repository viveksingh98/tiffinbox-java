package com.tiffinbox.web;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.PropertySource;

/**
 * The break: TiffinBoxApp's three annotations (@Configuration, @EnableAutoConfiguration, @ComponentScan("com.tiffinbox"))
 * swapped for the one every Boot tutorial starts with. @PropertySource stays, so the swap is the only difference.
 * receipts.sh copies after/ to .harness/swap/, puts this file over TiffinBoxApp.java there, builds it, and runs
 * java -jar tiffinbox-web-1.0.0.jar 18545. Measured: exit 1 - the scan starts at com.tiffinbox.web, this class's own
 * package, and never reaches com.tiffinbox, where tiffinbox-core's CustomerRepository lives.
 */
@SpringBootApplication
@PropertySource("classpath:tiffinbox.properties")
public class TiffinBoxApp {
}
