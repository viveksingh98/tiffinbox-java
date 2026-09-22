package com.tiffinbox;

/**
 * The one that talks to the H2 the long-lived project already ships.
 *
 * <p>IT IS CALLED THE JDBC RAIL, NOT THE PRODUCTION RAIL, and that is deliberate. H2 is what
 * Course 2 shipped and what this course carries; whether it is what you would run a business on is
 * a different question, asked in a different course. A profile name that says "prod" would have
 * answered it by accident.
 */
public class JdbcRail implements Rail {

    private final String url;

    public JdbcRail(String url) { this.url = url; }

    @Override public String describe() { return "jdbc rail (" + url + ")"; }
}
