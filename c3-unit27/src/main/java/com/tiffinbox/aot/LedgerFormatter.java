package com.tiffinbox.aot;

import com.tiffinbox.Customer;

import java.sql.Types;
import java.util.List;

/**
 * The second formatter, and the one that costs something: it touches java.sql.
 *
 * <p>Types.INTEGER is a constant in the java.sql module. Nothing else in this program needs
 * that module at run time except the database code - so a runtime image built for the
 * program as the tools can SEE it still contains java.sql, and a runtime image built for
 * the program as somebody TRIMMED it might not. This class is how you find out.
 */
public final class LedgerFormatter implements Formatter {
    @Override
    public String render(List<Customer> roster) {
        var sb = new StringBuilder();
        sb.append("column type: ").append(Types.INTEGER).append('\n');
        int total = 0;
        for (Customer c : roster) {
            total += c.monthlyBill();
        }
        sb.append("customers: ").append(roster.size()).append('\n');
        sb.append("month total: ").append(total).append('\n');
        return sb.toString();
    }
}
