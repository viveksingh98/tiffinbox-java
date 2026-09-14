import java.util.List;
import java.util.Optional;

/// The generics unit's Repository, extended: save() now returns the saved item and
/// deleteById() replaced count(). findById and findAll are exactly as they were.
/// Still no java.sql anywhere in it — that is the part that must not change.
public interface Repository<T, ID> {
    Optional<T> findById(ID id);
    List<T> findAll();
    T save(T item);
    boolean deleteById(ID id);
}
