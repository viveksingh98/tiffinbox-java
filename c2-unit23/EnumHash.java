// EnumHash.java — CUT FROM THE DECK ON PURPOSE. Evidence only; never put this output on a slide.
// On JDK 25.0.4.1 this printed {VEG=11700, NON_VEG=9000, VEGAN=3600} on 8 consecutive runs — the same
// order an EnumMap gives. That is an identity-hash accident, NOT a property of HashMap. A HashMap makes
// no ordering promise of any kind; teaching this output as "HashMap keeps enum order" would be false.
import java.util.*;
enum MealType { VEG, NON_VEG, VEGAN }
void main() {
    Map<MealType,Integer> h = new HashMap<>();
    h.put(MealType.VEGAN, 3600); h.put(MealType.VEG, 11700); h.put(MealType.NON_VEG, 9000);
    IO.println("HashMap : " + h);
}
