package com.tiffinbox;

import com.tiffinbox.aot.Formatter;
import com.tiffinbox.aot.Startup;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/** Both formatters resolve by name, and both render the same roster. */
class StartupTest {

    @Test
    void bothFormattersResolveByName() throws Exception {
        Formatter plain = Startup.formatterNamed("plain");
        Formatter ledger = Startup.formatterNamed("ledger");
        assertThat(plain.getClass().getName()).endsWith("PlainFormatter");
        assertThat(ledger.getClass().getName()).endsWith("LedgerFormatter");
    }

    @Test
    void theRosterRenders() throws Exception {
        var db = new Database("jdbc:h2:mem:unit27test;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        List<Customer> roster = new CustomerRepository(db).findAll();
        assertThat(roster).hasSize(4);
        assertThat(Startup.formatterNamed("plain").render(roster)).contains("Meera");
        assertThat(Startup.formatterNamed("ledger").render(roster)).contains("month total");
    }
}
