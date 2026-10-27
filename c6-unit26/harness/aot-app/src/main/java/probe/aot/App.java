package probe.aot;

import java.lang.reflect.Proxy;
import java.util.Arrays;
import java.util.Locale;
import org.springframework.aop.support.AopUtils;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

/** The course's harness: the AOT app's main class. Its runner prints what answers for Payments, and pays once ("AOT ..." lines). */
@SpringBootApplication
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Bean
    CommandLineRunner payOnce(Payments payments) {
        return args -> {
            Class<?> k = payments.getClass();
            System.out.println("AOT the JVM's locale: " + Locale.getDefault());
            System.out.println("AOT proxy class: " + k.getName() + " | Proxy.isProxyClass: " + Proxy.isProxyClass(k)
                    + " | AopUtils.isJdkDynamicProxy: " + AopUtils.isJdkDynamicProxy(payments));
            System.out.println("AOT proxy interfaces: " + Arrays.stream(k.getInterfaces()).map(Class::getName).sorted().toList());
            System.out.println("AOT pay -> " + payments.pay(new Charge("Ravi", 7200)));
        };
    }
}
