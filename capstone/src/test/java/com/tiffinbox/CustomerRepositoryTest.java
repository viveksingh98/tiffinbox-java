package com.tiffinbox;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class CustomerRepositoryTest {

    @TempDir
    Path folder;

    @Test
    void saveThenLoadGivesTheSameCustomers() {
        var repository = new CustomerRepository(folder.resolve("customers.csv"));
        var customers = List.of(
                new Customer("Ravi", 2, 120, true),
                new Customer("Meera", 1, 150, false));

        repository.save(customers);

        assertEquals(customers, repository.load());
    }

    @Test
    void missingFileMeansNoCustomers() {
        var repository = new CustomerRepository(folder.resolve("nothing-here.csv"));
        assertEquals(List.of(), repository.load());
    }

    @Test
    void badLineIsSkippedNotFatal() throws IOException {
        var file = folder.resolve("customers.csv");
        Files.writeString(file, Customer.CSV_HEADER + "\nRavi,2,120,true\nSunil,two,120,true\n");

        var loaded = new CustomerRepository(file).load();

        assertEquals(1, loaded.size());
        assertEquals("Ravi", loaded.getFirst().name());
    }
}
