package trap;

import com.tiffinbox.autoconfigure.KitchenAutoConfiguration;
import com.tiffinbox.kitchen.Kitchen;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.NoUniqueBeanDefinitionException;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.context.TypeExcludeFilter;
import org.springframework.boot.autoconfigure.AutoConfigurationExcludeFilter;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.core.annotation.AnnotatedElementUtils;
import org.springframework.core.annotation.MergedAnnotations;
import org.springframework.stereotype.Component;
import org.springframework.core.type.classreading.SimpleMetadataReaderFactory;

/**
 * What C and D print, in this order:
 *   0. what a component scan finds on the starter's class: @Component, and the annotations it is reached through;
 *   1. the application class's own component scan, merged the way Spring reads it: its packages and its exclude filters;
 *   2. when the scan has Boot's AutoConfigurationExcludeFilter, that filter's own answer about the starter's class;
 *   3. after the context has started: the Kitchen beans in the order their definitions were registered
 *      (getBeanDefinitionNames() keeps registration order), and the bean name the starter's configuration class got -
 *      a scanned class is named by the scan (kitchenAutoConfiguration), an imported one by its full class name;
 *   4. what a caller gets when it asks the context for ONE Kitchen.
 * Nothing here is in com.tiffinbox, so the scan of com.tiffinbox below finds only the starter's classes.
 */
final class Kitchens {
    private Kitchens() { }

    static void run(Class<?> app, String[] args) throws Exception {
        List<String> path = MergedAnnotations.from(KitchenAutoConfiguration.class).get(Component.class).getMetaTypes()
                .stream().map(t -> "@" + t.getSimpleName()).toList();
        System.out.println("KitchenAutoConfiguration carries " + path.get(path.size() - 1) + ": " + String.join(" → ", path));
        ComponentScan scan = AnnotatedElementUtils.getMergedAnnotation(app, ComponentScan.class);
        List<Class<?>> filters = Arrays.stream(scan.excludeFilters()).flatMap(f -> Arrays.stream(f.classes())).toList();
        System.out.println("its scan: basePackages " + Arrays.toString(scan.basePackages()) + " · exclude filters "
                + filters.stream().map(Class::getSimpleName).toList());
        if (filters.contains(AutoConfigurationExcludeFilter.class)) {
            ClassLoader loader = Kitchens.class.getClassLoader();
            AutoConfigurationExcludeFilter filter = new AutoConfigurationExcludeFilter();
            filter.setBeanClassLoader(loader);
            SimpleMetadataReaderFactory readers = new SimpleMetadataReaderFactory(loader);
            String starter = KitchenAutoConfiguration.class.getName();
            System.out.println("AutoConfigurationExcludeFilter, asked about " + starter + ": match "
                    + filter.match(readers.getMetadataReader(starter), readers));
        }
        if (!filters.isEmpty() && !filters.equals(List.of(TypeExcludeFilter.class, AutoConfigurationExcludeFilter.class))) {
            throw new IllegalStateException("unexpected exclude filters: " + filters);
        }
        try (var ctx = SpringApplication.run(app, args)) {
            var bf = ctx.getBeanFactory();
            Set<String> kitchens = Set.of(ctx.getBeanNamesForType(Kitchen.class));
            System.out.println("Kitchen beans, in the order they were registered: "
                    + Arrays.stream(bf.getBeanDefinitionNames()).filter(kitchens::contains).toList());
            System.out.println("the starter's configuration class, registered as: "
                    + String.join(", ", ctx.getBeanNamesForType(KitchenAutoConfiguration.class)));
            try {
                System.out.println("asking for one Kitchen: " + ctx.getBean(Kitchen.class).describe());
            } catch (NoUniqueBeanDefinitionException e) {
                System.out.println("asking for one Kitchen: " + e.getClass().getSimpleName() + ": " + e.getMessage());
            }
        }
    }
}
