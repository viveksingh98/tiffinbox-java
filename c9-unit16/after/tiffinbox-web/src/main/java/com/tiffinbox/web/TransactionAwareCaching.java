package com.tiffinbox.web;

import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.cache.CacheManager;
import org.springframework.cache.transaction.AbstractTransactionSupportingCacheManager;
import org.springframework.cache.transaction.TransactionAwareCacheManagerProxy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

/**
 * Course 9, unit 04: every cache put, evict and clear made inside a transaction runs after its commit. Boot's CacheManager is kept
 * as Boot built it (its cache names, Caffeine's spec, the metrics) and wrapped in Spring's TransactionAwareCacheManagerProxy - unless
 * it is already transaction-aware, so no manager is decorated twice. Inside the Idempotency-Key's transaction, add's eviction would
 * otherwise run when add returns, before the commit, and a read in between would cache the old list again. Off with
 * tiffinbox.cache.transaction-aware=false (the A/B pair).
 */
@Configuration(proxyBeanMethods = false)
class TransactionAwareCaching {

    private static final System.Logger LOG = System.getLogger("tiffinbox");

    @Bean
    static BeanPostProcessor transactionAwareCacheManager(Environment env) {
        boolean on = env.getProperty("tiffinbox.cache.transaction-aware", Boolean.class, true);
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                if (!(bean instanceof CacheManager manager)) {
                    return bean;
                }
                String what = "the CacheManager bean '" + name + "' (" + bean.getClass().getSimpleName() + ")";
                if (!on) {
                    LOG.log(System.Logger.Level.INFO, "CACHE " + what + " left as Boot built it (tiffinbox.cache.transaction-aware=false)");
                    return bean;
                }
                if (manager instanceof TransactionAwareCacheManagerProxy
                        || (manager instanceof AbstractTransactionSupportingCacheManager t && t.isTransactionAware())) {
                    LOG.log(System.Logger.Level.INFO, "CACHE " + what + " is transaction-aware already: not wrapped again");
                    return bean;
                }
                LOG.log(System.Logger.Level.INFO, "CACHE " + what + " wrapped in TransactionAwareCacheManagerProxy: evictions after the commit");
                return new TransactionAwareCacheManagerProxy(manager);
            }
        };
    }
}
