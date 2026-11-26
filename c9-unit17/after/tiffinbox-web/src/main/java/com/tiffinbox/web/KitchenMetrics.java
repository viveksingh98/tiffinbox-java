package com.tiffinbox.web;

import com.tiffinbox.OrderQueue;
import io.micrometer.core.instrument.FunctionCounter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.binder.MeterBinder;
import org.springframework.aot.hint.MemberCategory;
import org.springframework.aot.hint.annotation.RegisterReflection;
import org.springframework.stereotype.Component;

/**
 * The kitchen's count, as two meters: tiffinbox.orders.cooked and tiffinbox.orders.value read the kitchen's own getters
 * each time a registry is read - at a scrape. The kitchen counts; the meters only read.
 *
 * <p>Course 5: a MeterBinder bean is handed the registry Boot made, and registers its meters there. A FunctionCounter is
 * Micrometer's counter for a count someone else keeps, so tiffinbox-core does not change and does not depend on
 * Micrometer.
 *
 * <p>Course 5: the native binary. Micrometer's processor meters call the JDK's operating-system bean through
 * com.sun.management.OperatingSystemMXBean, by reflection, and Micrometer's own native-image metadata lists three of the
 * methods it calls, not getProcessCpuTime(): without this hint the binary's scrape failed with a
 * MissingReflectionRegistrationError. The hint registers the interface's public methods for reflection.
 */
@Component
@RegisterReflection(classNames = "com.sun.management.OperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)
public final class KitchenMetrics implements MeterBinder {

    private final OrderQueue kitchen;

    KitchenMetrics(OrderQueue kitchen) {
        this.kitchen = kitchen;
    }

    @Override
    public void bindTo(MeterRegistry registry) {
        FunctionCounter.builder("tiffinbox.orders.cooked", kitchen, OrderQueue::cooked)
                .description("Orders the kitchen cooked")
                .register(registry);
        FunctionCounter.builder("tiffinbox.orders.value", kitchen, OrderQueue::cookedValue)
                .description("What the cooked orders are worth")
                .register(registry);
    }
}
