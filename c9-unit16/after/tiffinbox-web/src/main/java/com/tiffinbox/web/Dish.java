package com.tiffinbox.web;

import com.tiffinbox.DishEntity;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;
import org.springframework.data.elasticsearch.annotations.Setting;

/**
 * Course 8, unit 21: a dish as Elasticsearch's index dishes holds it - a copy of a dish row (DishEntity, PostgreSQL's under the
 * profile "dev"), never the source. Its id is the row's id, as a String (an Elasticsearch document's id is a string). Spring Data
 * Elasticsearch reads this class at start: the repository (Dishes) creates the index when it is missing, with the settings of
 * dish-settings.json (@Setting) and a mapping from the @Field lines - name a text field analysed by "dish", mealType a keyword (one
 * token, the value as written), price an integer. The mapper also writes _class (the type hint) into every document, and the record's
 * id lands in the document's body too, as a dynamic text field (../c8-unit21, anchor's _mapping).
 *
 * <p>The analyzer "dish" (dish-settings.json): the standard tokenizer, lowercase, then a synonym filter "veg, vegetarian" - so the
 * tokens the index stores for Vegetarian Lunch Box are vegetarian, veg, lunch and box, and a search for veg finds that dish and no
 * other (../c8-unit21, anchor and tokens). With the standard analyzer alone the same search finds none (../c8-unit21, nohit).
 * number_of_replicas 0: one node holds the one copy, and the index answers green.
 */
@Document(indexName = "dishes")
@Setting(settingPath = "dish-settings.json")
public record Dish(@Id String id,
                   @Field(type = FieldType.Text, analyzer = "dish") String name,
                   @Field(type = FieldType.Keyword) String mealType,
                   @Field(type = FieldType.Integer) int price) {

    /** The copy of one row: its id, name, meal type and price. */
    static Dish of(DishEntity row) {
        return new Dish(String.valueOf(row.getId()), row.getName(), row.getMealType().name(), row.getPrice());
    }
}
