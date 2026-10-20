package probe.web;

import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.List;
import java.util.stream.IntStream;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources. Two routes that fail after the
 * answer has started to leave. /probe/committed writes a line, flushes it - the status and the headers go out with it: the
 * response is committed - and then throws. /probe/meals returns 2,000 meals; Jackson writes them as it goes, and the 1,500th
 * fails as it is written, long after Tomcat's buffer has filled and gone out. /probe/short returns 10 short meals whose 5th fails
 * the same way, before anything has gone out - the answer is not committed yet.
 */
@RestController
public class Committed {

    @GetMapping("/probe/committed")
    void committed(HttpServletResponse response) throws IOException {
        response.setContentType("text/plain");
        response.getWriter().write("half an answer\n");
        response.flushBuffer();
        throw new IllegalStateException("the second half burned");
    }

    @GetMapping("/probe/meals")
    List<Meal> meals() {
        return IntStream.rangeClosed(1, 2000).mapToObj(Meal::new).toList();
    }

    @GetMapping("/probe/short")
    List<ShortMeal> few() {
        return IntStream.rangeClosed(1, 10).mapToObj(ShortMeal::new).toList();
    }

    /** A meal - its number, and a name that cannot be written for the 1,500th. */
    public static final class Meal {
        private final int number;

        Meal(int number) {
            this.number = number;
        }

        public int getNumber() {
            return number;
        }

        public String getName() {
            if (number == 1500) {
                throw new IllegalStateException("meal 1500 burned");
            }
            return "meal " + number;
        }
    }

    /** A meal of the short list - its number, and a name that cannot be written for the 5th. */
    public static final class ShortMeal {
        private final int number;

        ShortMeal(int number) {
            this.number = number;
        }

        public int getNumber() {
            return number;
        }

        public String getName() {
            if (number == 5) {
                throw new IllegalStateException("meal 5 burned");
            }
            return "meal " + number;
        }
    }
}
