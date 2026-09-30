package com.tiffinbox.harness;

import org.springframework.beans.factory.annotation.Value;

/**
 * The same typo as {@link MaelByValue} - {@code mael} for {@code meal} - WITH a default after the colon: the last course's
 * other case. {@link Placeholders} registers it by code; the class carries no annotation, so TiffinBox's component scan
 * never registers it.
 */
public final class MaelWithDefault {

    final String mael;

    public MaelWithDefault(@Value("${tiffinbox.mael:VEG}") String mael) {
        this.mael = mael;
    }
}
