package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.BDDMockito.given;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.BDDMockito.willThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.request;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.Database;
import com.tiffinbox.OrderQueue;
import jakarta.servlet.ServletException;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.assertj.MockMvcTester;
import slice.WebSlice;

/**
 * Course 6: TiffinBox's first tests - a test slice of the web layer.
 *
 * <p>{@code @WebMvcTest} starts Spring MVC and TiffinBox's controllers, its advice and its page, and leaves the rest out: the
 * database, the kitchen, the health indicator, the meters. The three classes the controllers need from tiffinbox-core are mocks
 * ({@code @MockitoBean}: a stand-in Mockito makes, which answers only what a test tells it). Requests go through MockMvc - Spring's
 * request simulator: the DispatcherServlet runs, with no socket and no Tomcat. {@code MockMvcTester} is its AssertJ form.
 *
 * <p>The shutdown token is a literal written here, not a secret: these tests run in tiffinbox-web/, where no secrets/ folder is,
 * and TiffinBox's settings record will not start without a token.
 *
 * <p>The capstone's five tests (after the dashboard's page): the name's length, twice; the bulk upload; the form; the feed. The
 * feed's answer never ends, so its test uses MockMvc's {@code perform} and {@code request().asyncStarted()}: MockMvcTester waits
 * for an async answer's result, and an event stream has none to wait for. FeedTest hears the feed's events, on a real server.
 */
@WebMvcTest(properties = "tiffinbox.shutdown-token=not-the-real-token")
@ContextConfiguration(classes = WebSlice.class)
class TiffinBoxWebTest {

    /** A customer who breaks three of Customer's rules: no name, no meals, no price. */
    private static final String INVALID = "{\"name\":\"\",\"mealsPerDay\":0,\"pricePerMeal\":0,\"mealType\":\"VEG\"}";

    /** A customer whose name is the only thing that can be wrong. */
    private static String customer(String name) {
        return "{\"name\":\"" + name + "\",\"mealsPerDay\":1,\"pricePerMeal\":100,\"mealType\":\"VEG\"}";
    }

    @Autowired MockMvcTester tester;
    @Autowired MockMvc mvc;
    @Autowired ApplicationContext context;

    @MockitoBean CustomerRepository repo;
    @MockitoBean Dashboard dashboard;
    @MockitoBean OrderQueue kitchen;

    /** Surefire's JVM takes its options from the POM's argLine - the locale every run line pins. */
    @Test
    void theTestsRunInEnglish() {
        System.out.println("the test JVM's locale: " + Locale.getDefault());
        assertThat(Locale.getDefault()).isEqualTo(Locale.US);
    }

    @Test
    void theSliceLeavesTheDatabaseOut() {
        assertThat(context.getBeanNamesForType(Database.class)).isEmpty();
    }

    @Test
    void customersAreJson() throws Exception {
        given(repo.findAll()).willReturn(List.of(new Customer("Ravi", 2, 120, "VEG")));
        assertThat(tester.get().uri("/customers"))
                .hasStatusOk()
                .hasContentType(MediaType.APPLICATION_JSON)
                .bodyJson().extractingPath("$[0].name").isEqualTo("Ravi");
    }

    /** TiffinBoxErrors' own problem detail: it names him. */
    @Test
    void aNameNobodyHasIsAProblemDetail() {
        assertThat(tester.get().uri("/customers/{name}", "Nobody"))
                .hasStatus(HttpStatus.NOT_FOUND)
                .hasContentType(MediaType.APPLICATION_PROBLEM_JSON)
                .bodyJson().extractingPath("$.name").isEqualTo("Nobody");
    }

    /** No Accept-Language: MockMvc's request says English, whatever the JVM's locale. */
    @Test
    void anInvalidCustomerBreaksThreeRules() {
        assertThat(tester.post().uri("/customers").contentType(MediaType.APPLICATION_JSON).content(INVALID))
                .hasStatus(HttpStatus.BAD_REQUEST)
                .hasContentType(MediaType.APPLICATION_PROBLEM_JSON)
                .bodyJson().isLenientlyEqualTo("""
                        {"detail": "the customer breaks 3 rules",
                         "errors": {"mealsPerDay": "must be greater than or equal to 1",
                                    "name": "must not be blank",
                                    "pricePerMeal": "must be greater than or equal to 1"}}""");
    }

    @Test
    void anInvalidCustomerInGerman() {
        assertThat(tester.post().uri("/customers").contentType(MediaType.APPLICATION_JSON).header("Accept-Language", "de")
                .content(INVALID))
                .hasStatus(HttpStatus.BAD_REQUEST)
                .bodyJson().isLenientlyEqualTo("""
                        {"errors": {"mealsPerDay": "muss größer-gleich 1 sein",
                                    "name": "darf nicht leer sein",
                                    "pricePerMeal": "muss größer-gleich 1 sein"}}""");
    }

    /** Spring MVC's 405; its body is a problem detail because TiffinBox switched them on (spring.mvc.problemdetails.enabled). */
    @Test
    void shutdownIsNotAGet() {
        assertThat(tester.get().uri("/shutdown"))
                .hasStatus(HttpStatus.METHOD_NOT_ALLOWED)
                .hasHeader("Allow", "POST");
    }

    @Test
    void theDashboardIsAPage() throws Exception {
        given(dashboard.load()).willReturn(new Dashboard.View(List.of(new Customer("Ravi", 2, 120, "VEG")), 7200, 0));
        assertThat(tester.get().uri("/dashboard").accept(MediaType.TEXT_HTML))
                .hasStatusOk()
                .hasContentTypeCompatibleWith(MediaType.TEXT_HTML)
                .bodyText().contains("<title>Dashboard · TiffinBox</title>");
    }

    /** Sixty-one letters: one rule, Size - a 400 before any SQL runs (the table's column holds sixty). */
    @Test
    void aSixtyOneLetterNameIsRefused() {
        assertThat(tester.post().uri("/customers").contentType(MediaType.APPLICATION_JSON).content(customer("A".repeat(61))))
                .hasStatus(HttpStatus.BAD_REQUEST)
                .hasContentType(MediaType.APPLICATION_PROBLEM_JSON)
                .bodyJson().isLenientlyEqualTo("""
                        {"detail": "the customer breaks 1 rule",
                         "errors": {"name": "size must be between 0 and 60"}}""");
    }

    /** Sixty-one spaces: blank and too long - two rules, both messages for the one field, sorted. */
    @Test
    void sixtyOneSpacesBreakBothRules() {
        assertThat(tester.post().uri("/customers").contentType(MediaType.APPLICATION_JSON).content(customer(" ".repeat(61))))
                .hasStatus(HttpStatus.BAD_REQUEST)
                .bodyJson().isLenientlyEqualTo("""
                        {"detail": "the customer breaks 2 rules",
                         "errors": {"name": "must not be blank; size must be between 0 and 60"}}""");
    }

    /** A bulk upload: the good row is stored, each other row is named by its line, with why. */
    @Test
    void anUploadAddsTheGoodRowAndNamesTheRest() throws Exception {
        willThrow(new SQLException("taken", "23505")).given(repo).add(argThat(c -> c.name().equals("Ravi")));
        var csv = new MockMultipartFile("file", "customers.csv", "text/csv", ("name,mealsPerDay,pricePerMeal,mealType\n"
                + "Chetan,1,100,VEG\n" + "A".repeat(61) + ",1,100,VEG\nDev,x,90,VEGAN\nRavi,2,120,VEG\n")
                .getBytes(StandardCharsets.UTF_8));
        assertThat(tester.post().uri("/customers/import").multipart().file(csv))
                .hasStatusOk()
                .bodyJson().isStrictlyEqualTo("""
                        {"file": "customers.csv", "added": 1,
                         "refused": {"line 3": "name: size must be between 0 and 60",
                                     "line 4": "not a number: For input string: \\"x\\"",
                                     "line 5": "a customer named Ravi already exists"}}""");
    }

    @Test
    void theFormIsAPage() {
        assertThat(tester.get().uri("/customers/new").accept(MediaType.TEXT_HTML))
                .hasStatusOk()
                .bodyText().contains("<form");
    }

    /** An answer that stays open: MockMvc sees it start; a test that waited for its end would wait for ever. */
    @Test
    void theFeedIsAnEventStream() throws Exception {
        mvc.perform(get("/customers/feed").accept(MediaType.TEXT_EVENT_STREAM))
                .andExpect(request().asyncStarted());
    }

    /**
     * What a slice cannot show: a repository that throws leaves no status and no body. Nobody handled the exception, and
     * MockMvc runs no error dispatch - no /error, no error page: the request failed, and the failure is the result. The older
     * MockMvc API throws it instead.
     */
    @Test
    void aFailingRepositoryLeavesNoStatus() throws Exception {
        given(repo.monthRevenue()).willThrow(new IllegalStateException("kitchen on fire"));
        assertThat(tester.get().uri("/revenue"))
                .hasFailed()
                .failure().hasMessageContaining("kitchen on fire");
        assertThatThrownBy(() -> mvc.perform(get("/revenue")))
                .isInstanceOf(ServletException.class)
                .hasMessageContaining("kitchen on fire");
    }
}
