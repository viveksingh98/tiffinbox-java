package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import jakarta.validation.Valid;
import org.springframework.aot.hint.MemberCategory;
import org.springframework.aot.hint.RuntimeHints;
import org.springframework.aot.hint.RuntimeHintsRegistrar;
import org.springframework.context.annotation.ImportRuntimeHints;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.sql.SQLException;

/**
 * Course 6: TiffinBox's pages. A {@code @Controller}, not a {@code @RestController}: a route's return value here is a view's
 * name, not the answer's body. Spring MVC hands the name to Thymeleaf's view resolver, which reads
 * {@code templates/<name>.html} from the class path and fills its {@code th:*} attributes from the model - what the route put
 * in its {@code Model} - on the server; the client gets finished HTML. The page's head, header and footer are fragments of
 * {@code templates/fragments.html}, which both pages pull in. Three routes:
 * <ul>
 * <li>GET /dashboard, for a client that ranks HTML first ({@code produces = text/html}): the dashboard as a page.
 *     TiffinBoxServer's GET /dashboard names no type and stays the JSON answer: curl's own Accept, {@code *}{@code /*}, still
 *     gets JSON.</li>
 * <li>GET /customers/new, for HTML: the form, filled from its form-backing object - a Customer whose fields the form's inputs
 *     show, and which a POST binds back.</li>
 * <li>POST /customers with a form's body ({@code consumes = application/x-www-form-urlencoded}): Spring MVC binds the form's
 *     fields onto a new Customer ({@code @ModelAttribute}) and checks it ({@code @Valid}); the rules it broke are in the
 *     BindingResult, and the form is shown again with each message beside its field. A name that is taken - H2's SQLSTATE
 *     23505, read as TiffinBoxServer reads it - is one more message, on the name. Stored: CustomerFeed's listeners hear the
 *     new customer (since the capstone, as they hear the JSON API's), and a redirect to the dashboard (302),
 *     redirect-after-POST: the browser asks for the page with a GET, so a reload never sends the form again. The redirect
 *     carries a note: a flash attribute ("added", the customer's name), which Spring MVC keeps in the client's session until
 *     the redirect's GET /dashboard has read it, then drops - the page shows "... added" once. Keeping it is what makes the
 *     session: the answer sets the session cookie, JSESSIONID, and only the cookie carries the session's id, never the
 *     address (server.servlet.session.tracking-modes: cookie, application.yaml). Every other
 *     refusal stays Spring MVC's 500 - for a client that asks for HTML, {@code templates/error/5xx.html}. A JSON body still
 *     goes to TiffinBoxServer's POST /customers.</li>
 * </ul>
 * <p>The native image: Thymeleaf reads the model's records through SpEL, by reflection, and nothing tells Spring's AOT step
 * which types a template reads - so TemplateHints registers the two, Dashboard.View and Customer. The customer count is
 * computed here, in Java, so the template calls no method on a type nobody registered (the JDK's own list class among them).
 * The form carries no CSRF token: Course 10's subject.
 */
@Controller
@ImportRuntimeHints(DashboardPage.TemplateHints.class)
final class DashboardPage {

    /** H2's SQLSTATE for a row whose name is already in the table (TiffinBoxServer's NAME_TAKEN). */
    private static final String NAME_TAKEN = "23505";

    /** The two record types the templates read by reflection - registered for the native image. */
    static final class TemplateHints implements RuntimeHintsRegistrar {
        @Override
        public void registerHints(RuntimeHints hints, ClassLoader loader) {
            hints.reflection().registerType(Dashboard.View.class, MemberCategory.INVOKE_PUBLIC_METHODS);
            hints.reflection().registerType(Customer.class, MemberCategory.INVOKE_PUBLIC_METHODS);
        }
    }

    private final Dashboard dashboard;
    private final CustomerRepository repo;
    private final CustomerFeed feed;

    DashboardPage(Dashboard dashboard, CustomerRepository repo, CustomerFeed feed) {
        this.dashboard = dashboard;
        this.repo = repo;
        this.feed = feed;
    }

    @GetMapping(value = "/dashboard", produces = MediaType.TEXT_HTML_VALUE)
    String page(Model model) throws Exception {
        Dashboard.View view = dashboard.load();
        model.addAttribute("view", view);
        model.addAttribute("customerCount", view.customers().size());
        return "dashboard";
    }

    @GetMapping(value = "/customers/new", produces = MediaType.TEXT_HTML_VALUE)
    String form(Model model) {
        model.addAttribute("customer", new Customer("", 1, 120, "VEG"));
        return "customer-form";
    }

    @PostMapping(value = "/customers", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    String add(@Valid @ModelAttribute("customer") Customer customer, BindingResult errors, RedirectAttributes flash)
            throws SQLException {
        if (errors.hasErrors()) {
            return "customer-form";
        }
        try {
            repo.add(customer);
        } catch (SQLException e) {
            if (NAME_TAKEN.equals(e.getSQLState())) {
                errors.rejectValue("name", "taken", "a customer named " + customer.name() + " already exists");
                return "customer-form";
            }
            throw e;
        }
        feed.added(customer);
        flash.addFlashAttribute("added", customer.name());
        return "redirect:/dashboard";
    }
}
