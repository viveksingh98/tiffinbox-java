import java.util.List;
import java.util.concurrent.StructuredTaskScope;
import java.util.concurrent.StructuredTaskScope.Joiner;
import java.util.concurrent.StructuredTaskScope.Subtask;

static final ScopedValue<String> CURRENT_CUSTOMER = ScopedValue.newInstance();

static String line(String job) {
    String where = Thread.currentThread().isVirtual() ? "virtual" : "platform";
    return job + " for " + CURRENT_CUSTOMER.get() + " on a " + where + " thread";
}

void main() throws InterruptedException {
    IO.println("bound in main before where(): " + CURRENT_CUSTOMER.isBound());

    List<String> lines = ScopedValue.where(CURRENT_CUSTOMER, "Ravi").call(() -> {
        try (var scope = StructuredTaskScope.open(Joiner.<String>allSuccessfulOrThrow())) {
            scope.fork(() -> line("bill"));
            scope.fork(() -> line("pause check"));
            return scope.join().map(Subtask::get).sorted().toList();
        }
    });
    lines.forEach(IO::println);

    IO.println("bound in main after  where(): " + CURRENT_CUSTOMER.isBound());
}
