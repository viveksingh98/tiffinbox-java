public class TDotClass<T> {
    Class<?> type() {
        return T.class;
    }

    boolean isT(Object o) {
        return o instanceof T;
    }
}
