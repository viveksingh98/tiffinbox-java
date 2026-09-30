package com.tiffinbox.harness;

import org.springframework.context.ConfigurableApplicationContext;

/**
 * The record, printed whole - the one thing the rest of this harness never does. {@code Record <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}), prints the record's bean with {@code String.valueOf} - exactly what a
 * log line that names the settings object prints - then closes the context, which stops TiffinBox's server. It exists
 * to count one thing: how many raw copies of the token a whole-record print carries. receipts.sh counts them in the run's
 * own output, and masks every demo token in every capture (gsub) before anything is kept.
 */
public final class Record {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args);
        try {
            System.out.println("the record: " + ctx.getBean(Class.forName("com.tiffinbox.TiffinBoxProperties")));
        } finally {
            ctx.close();
        }
    }
}
