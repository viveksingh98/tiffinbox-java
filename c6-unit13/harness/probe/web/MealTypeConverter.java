package probe.web;

import com.tiffinbox.MealType;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

import java.util.Locale;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. A Converter - Spring's interface for turning a value of one type into another - from the text of a request to a
 * MealType. Boot adds every Converter bean in the context to Spring MVC's conversion service (the bean mvcConversionService),
 * which every controller's data binder asks: so it serves every route in the application, TiffinBox's own among them.
 *
 * <p>Case does not matter here: veg, Veg and VEG are all VEG - where Spring's own converter from a String to an enum asks for the
 * constant's exact name. A blank value is no meal type at all (null), as Spring's own converter has it: TiffinBox's
 * ?mealType= with no value stays "no filter". Locale.ROOT, so the upper-casing never follows the JVM's language. It is asked
 * for text Spring MVC binds - request parameters, path variables, headers - and never for a JSON body: Jackson reads bodies.
 */
@Component
public class MealTypeConverter implements Converter<String, MealType> {

    @Override
    public MealType convert(String source) {
        String s = source.trim();
        return s.isEmpty() ? null : MealType.valueOf(s.toUpperCase(Locale.ROOT));
    }
}
