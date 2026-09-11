package com.tiffinbox;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class CustomerRepository {

    private final Path path;

    public CustomerRepository(Path path) {
        this.path = path;
    }

    public List<Customer> load() {
        var customers = new ArrayList<Customer>();
        List<String> lines;
        try {
            lines = Files.readAllLines(path);
        } catch (NoSuchFileException e) {
            IO.println("No " + path + " yet, starting empty");
            return customers;
        } catch (IOException e) {
            throw new TiffinBoxException("could not read " + path, e);
        }
        for (int i = 1; i < lines.size(); i++) {
            var line = lines.get(i);
            if (line.isBlank()) continue;
            try {
                customers.add(Customer.fromCsv(line));
            } catch (NumberFormatException | TiffinBoxException e) {
                IO.println("Skipped line " + (i + 1) + ": " + e.getMessage() + " in '" + line + "'");
            }
        }
        return customers;
    }

    public void save(List<Customer> customers) {
        var text = new StringBuilder(Customer.CSV_HEADER).append("\n");
        for (var c : customers) {
            text.append(c.toCsv()).append("\n");
        }
        try {
            Files.writeString(path, text);
        } catch (IOException e) {
            throw new TiffinBoxException("could not write " + path, e);
        }
    }

    public Path path() {
        return path;
    }
}
