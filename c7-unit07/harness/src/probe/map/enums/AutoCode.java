package probe.map.enums;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

/** MealCode again, with autoApply = true: it applies itself to every MealType attribute that names no mapping of its own. */
@Converter(autoApply = true)
public class AutoCode implements AttributeConverter<MealType, String> {
    public String convertToDatabaseColumn(MealType t) {
        if (t == null) return null;
        return switch (t.name()) { case "VEG" -> "veg"; case "NON_VEG" -> "non-veg"; case "VEGAN" -> "vegan"; default -> "?" + t.name(); };
    }
    public MealType convertToEntityAttribute(String s) {
        if (s == null) return null;
        return MealType.valueOf(switch (s) { case "veg" -> "VEG"; case "non-veg" -> "NON_VEG"; case "vegan" -> "VEGAN"; default -> s; });
    }
}
