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
        excludeFilters = @ComponentScan.Filter(
                type = FilterType.ASSIGNABLE_TYPE,
                classes = com.tiffinbox.menu.CsvMenuRepository.class))
public class ScanConfig {
}
