package com.tiffinbox.harness;

import com.tiffinbox.MealType;
import org.springframework.beans.factory.annotation.Value;

/**
 * One meal type read the way TiffinBox's classes used to read their keys: a {@code @Value} placeholder on a constructor
 * parameter, here of an enum type. {@link Favourite} and {@link Convert} register it by code; the class carries no
 * annotation, so TiffinBox's component scan never registers it.
 */
public final class FavouriteByValue {

    final MealType favourite;

    public FavouriteByValue(@Value("${tiffinbox.favourite}") MealType favourite) {
        this.favourite = favourite;
    }
}
