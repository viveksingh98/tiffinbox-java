import java.util.function.Function;
import java.util.*;

public class WrongId {
    record Customer(String name) {}

    interface Repository<T, ID> {
        Optional<T> findById(ID id);
    }

    static class InMemoryRepository<T, ID> implements Repository<T, ID> {
        private final Map<ID, T> store = new LinkedHashMap<>();
        private final Function<T, ID> idOf;
        InMemoryRepository(Function<T, ID> idOf) { this.idOf = idOf; }
        public Optional<T> findById(ID id) { return Optional.ofNullable(store.get(id)); }
    }

    public static void main(String[] args) {
        Repository<Customer, String> customers = new InMemoryRepository<>(Customer::name);
        customers.findById(2);
    }
}
