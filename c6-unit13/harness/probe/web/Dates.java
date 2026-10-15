package probe.web;

import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.chrono.IsoChronology;
import java.time.format.DateTimeFormatterBuilder;
import java.time.format.FormatStyle;
import java.util.Locale;

/**
 * The course's harness, never TiffinBox's. Dates in a query string. /probe/date takes a LocalDate with no format named: Spring's
 * formatter for it reads the short date style of the request's locale - the JVM's, when the request names no language - and
 * else the ISO form, 2026-10-14. /probe/date/fmt and /probe/date/yy name a pattern on the parameter (@DateTimeFormat), and the
 * ISO form is still read when the pattern fails. /probe/date/pattern prints the short date pattern this request is read with.
 */
@RestController
public class Dates {

    @GetMapping("/probe/date")
    String plain(@RequestParam LocalDate on) {
        return "on=" + on + " · the JVM's locale: " + Locale.getDefault();
    }

    @GetMapping("/probe/date/fmt")
    String fmt(@RequestParam @DateTimeFormat(pattern = "dd/MM/yyyy") LocalDate on) {
        return "on=" + on;
    }

    @GetMapping("/probe/date/yy")
    String yy(@RequestParam @DateTimeFormat(pattern = "dd/MM/yy") LocalDate on) {
        return "on=" + on;
    }

    @GetMapping("/probe/date/pattern")
    String pattern() {
        Locale l = LocaleContextHolder.getLocale();
        return "the JVM's locale: " + Locale.getDefault() + " · this request's: " + l + " · its short date pattern: "
                + DateTimeFormatterBuilder.getLocalizedDateTimePattern(FormatStyle.SHORT, null, IsoChronology.INSTANCE, l);
    }
}
