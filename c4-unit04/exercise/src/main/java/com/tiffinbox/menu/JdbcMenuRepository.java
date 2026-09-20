package com.tiffinbox.menu;

import org.springframework.stereotype.Repository;

/**
 * The static initialiser is the instrument. It runs the first time the JVM LOADS this class —
 * so if it never prints, this class was registered without ever being loaded.
 */
@Repository
public class JdbcMenuRepository implements MenuRepository {
    static {
        System.out.println("  CLASS LOADED  JdbcMenuRepository");
    }

    @Override
    public int dishCount() {
        return JdbcMenuRepository.class.getSimpleName().length();
    }
}
