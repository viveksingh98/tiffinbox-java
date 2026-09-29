package com.tiffinbox.harness;

import org.springframework.beans.factory.annotation.Value;

/**
 * A placeholder with a typo - {@code mael} for {@code meal} - and no default after a colon, written the way TiffinBox's
 * classes used to read their keys. {@link Placeholders} registers it by code; the class carries no annotation, so
 * TiffinBox's component scan never registers it.
 */
public final class MaelByValue {

    final String mael;

    public MaelByValue(@Value("${tiffinbox.mael}") String mael) {
        this.mael = mael;
    }
}
