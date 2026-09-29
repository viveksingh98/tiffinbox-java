package com.tiffinbox.harness;

import org.springframework.beans.factory.annotation.Value;

import java.util.List;

/**
 * A reader of the meal-types list, written the way TiffinBox's own classes read their keys: one {@code @Value}
 * placeholder on a constructor parameter. {@link ByValue} registers it by code; the class itself carries no annotation,
 * so TiffinBox's component scan never registers it.
 */
public final class MealTypesByValue {

    final List<String> mealTypes;

    public MealTypesByValue(@Value("${tiffinbox.meal-types}") List<String> mealTypes) {
        this.mealTypes = mealTypes;
    }
}
