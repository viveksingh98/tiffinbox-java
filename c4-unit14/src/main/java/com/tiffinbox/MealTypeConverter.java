package com.tiffinbox;

import org.springframework.core.convert.converter.Converter;

/**
 * String to MealType, written by you.
 *
 * <p>The file says {@code non-veg}; the type system says {@code NON_VEG}. Something has to close
 * that gap, and this is that something: trim, upper-case, hyphen to underscore.
 *
 * <p>IT ALSO FAILS READABLY, WHICH IS HALF ITS JOB. The default
 * {@code Enum.valueOf} message names the constant it could not find but not the key it came from
 * or what the legal values were, so a bad line in a properties file produces an error about an
 * enum and no hint about which line. This one says all three.
 */
public class MealTypeConverter implements Converter<String, MealType> {

    @Override
    public MealType convert(String source) {
        String normalised = source.trim().toUpperCase().replace('-', '_');
        try {
            return MealType.valueOf(normalised);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(
                    "cannot convert \"" + source + "\" to a MealType"
                            + " (read as \"" + normalised + "\"). Legal values: "
                            + java.util.Arrays.toString(MealType.values()), e);
        }
    }
}
