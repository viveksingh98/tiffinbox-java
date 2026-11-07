package probe.q.repo;

import org.springframework.beans.factory.annotation.Value;

/** An open projection: the getter is a SpEL expression over the whole entity (target), so Spring Data loads the entity. */
public interface Label {
    @Value("#{target.name + ' ' + target.mealType}")
    String getLabel();
}
