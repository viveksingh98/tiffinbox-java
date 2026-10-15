package probe.web;

import com.tiffinbox.MealType;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.beans.PropertyEditorSupport;

/**
 * The course's harness, never TiffinBox's. A controller with binding rules of its own: its @InitBinder method runs for each
 * request this controller answers, on the data binder - the object Spring MVC makes to turn the request's text into this
 * method's values - before the binding. Two rules, for this controller alone: every String trimmed, and a blank one made null
 * (StringTrimmerEditor, true); and a MealType read from a short code - v, nv, vg - and nothing else. A rule registered on the
 * binder (a property editor, the JavaBeans way to read a value from text) is asked before the application's conversion service,
 * so here it beats a Converter bean. Plain is its twin, with none of this.
 */
@RestController
public class Binder {

    @InitBinder
    void rules(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
        binder.registerCustomEditor(MealType.class, new ShortMealCodes());
    }

    @GetMapping("/probe/binder/name")
    String name(@RequestParam String name) {
        return "name=[" + name + "]";
    }

    @GetMapping("/probe/binder/meal")
    String meal(@RequestParam MealType type) {
        return "type=" + type;
    }

    /** A MealType from a short code; any other text is refused, the full names too. */
    static final class ShortMealCodes extends PropertyEditorSupport {
        @Override
        public void setAsText(String text) {
            setValue(switch (text) {
                case "v" -> MealType.VEG;
                case "nv" -> MealType.NON_VEG;
                case "vg" -> MealType.VEGAN;
                default -> throw new IllegalArgumentException("not a short meal code: " + text);
            });
        }
    }
}
