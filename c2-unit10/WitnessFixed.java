import java.util.ArrayList;
import java.util.List;

class WitnessFixed {
    static <T> List<T> emptyLedger() { return new ArrayList<>(); }
    public static void main(String[] args) {
        List<String> fromTarget = emptyLedger();
        System.out.println("inferred from the target type: " + fromTarget);
        System.out.println("explicit witness:              " + WitnessFixed.<String>emptyLedger());
    }
}
