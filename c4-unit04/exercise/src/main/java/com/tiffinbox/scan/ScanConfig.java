package com.tiffinbox.scan;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;

/**
 * One base package, and one excludeFilter. CsvMenuRepository wears @Repository exactly like
 * its sibling; the filter is the only reason it is not a bean.
 */
@Configuration
@ComponentScan(
        basePackages = { "com.tiffinbox.menu", "com.tiffinbox.kitchen" },
        // This filter excludes by ANNOTATION, not by type - so it takes out every class
        // wearing @Repository, not the one class somebody meant. The context still starts.
        excludeFilters = @ComponentScan.Filter(
                type = FilterType.ANNOTATION,
                classes = org.springframework.stereotype.Repository.class))
public class ScanConfig {
}
