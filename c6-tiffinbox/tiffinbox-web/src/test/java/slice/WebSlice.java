package slice;

import com.tiffinbox.TiffinBoxProperties;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.context.TypeExcludeFilter;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;

/**
 * Course 6: the configuration TiffinBox's web slice starts from - test sources only, never the application's.
 *
 * <p>A test slice ({@code @WebMvcTest}) looks for a {@code @SpringBootConfiguration} in the test's package and every package above
 * it, and TiffinBoxApp is not one: it is Course 5's hand-built three annotations, {@code @Configuration},
 * {@code @EnableAutoConfiguration} and {@code @ComponentScan("com.tiffinbox")}. This class is what a
 * {@code @SpringBootApplication} would have given the slice: the same scan, with Boot's {@code TypeExcludeFilter} - the filter
 * a slice uses to leave out every class it does not test (the database, the kitchen) - and TiffinBox's settings record.
 *
 * <p>It lives outside com.tiffinbox on purpose: there, TiffinBoxApp's own scan would find it in a test that starts the whole
 * application, and add it to that context too.
 */
@SpringBootConfiguration
@ComponentScan(basePackages = "com.tiffinbox",
        excludeFilters = @ComponentScan.Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class))
@EnableConfigurationProperties(TiffinBoxProperties.class)
public class WebSlice {
}
