package com.tiffinbox.menu;

import org.springframework.stereotype.Repository;

/**
 * The static initialiser is the instrument. It runs the first time the JVM LOADS this class —
 * so if it never prints, this class was registered without ever being loaded.
 */
@Repository
public class CsvMenuRepository implements MenuRepository {
    static {
        System.out.println("  CLASS LOADED  CsvMenuRepository");
    }

    @Override
    public int dishCount() {
        return CsvMenuRepository.class.getSimpleName().length();
    }
}
