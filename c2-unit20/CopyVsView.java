import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Set;

/** Collections.unmodifiableList is a window. List.copyOf is a snapshot. */
void main() {
    List<String> backing = new ArrayList<>(List.of("Meera", "Priya", "Ravi"));
    List<String> view = Collections.unmodifiableList(backing);
    List<String> copy = List.copyOf(backing);

    IO.println("view: " + view + "  copy: " + copy);
    backing.add("Sunil");
    IO.println("after backing.add(\"Sunil\")");
    IO.println("view: " + view + "  copy: " + copy);
    IO.println("view.size(): " + view.size() + "   copy.size(): " + copy.size());
    IO.println("view class: " + view.getClass().getName());
    IO.println("copy class: " + copy.getClass().getName());
    IO.println("view.add  -> " + refused(view));
    IO.println("copy.add  -> " + refused(copy));

    // does copyOf copy something already immutable?
    List<String> of = List.of("Meera", "Priya");
    List<String> one = List.of("Kiran");
    IO.println("copyOf(copy)  == copy  : " + (List.copyOf(copy) == copy));
    IO.println("copyOf(of)    == of    : " + (List.copyOf(of) == of));
    IO.println("copyOf(1-elem)== it    : " + (List.copyOf(one) == one));
    IO.println("copyOf(view)  == view  : " + (List.copyOf(view) == view));
    IO.println("copyOf(view)           : " + List.copyOf(view));

    // nulls and duplicates
    List<String> withNull = new ArrayList<>(Arrays.asList("Meera", null));
    try {
        List.copyOf(withNull);
    } catch (NullPointerException e) {
        IO.println("List.copyOf(list with null) -> NullPointerException");
    }
    IO.println("unmodifiableList(list with null) -> "
            + Collections.unmodifiableList(withNull) + "  (accepted)");
    try {
        Set.of("VEG", "NON_VEG", "VEG");
    } catch (IllegalArgumentException e) {
        IO.println("Set.of duplicate -> " + e);
    }
}

String refused(List<String> l) {
    try {
        l.add("Kiran");
        return "accepted (!)";
    } catch (UnsupportedOperationException e) {
        return "UnsupportedOperationException";
    }
}
