package com.tiffinbox.web;

import com.tiffinbox.MealType;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * Course 8, unit 22: POST /dishes - a new dish, as JSON (name, mealType, price), saved as a row by DishService; 201 and the saved
 * dish with the id PostgreSQL assigned. Under the profile "dev" only, beside DishSearch: on the default run the route answers 404 and
 * the default run prints the lines it printed before this unit (../c8-unit22, default).
 */
@RestController
@Profile("dev")
public class DishWrite {

    /** The request's body. */
    public record NewDish(String name, MealType mealType, int price) {
    }

    private final DishService service;

    DishWrite(DishService service) {
        this.service = service;
    }

    /** 201 and the dish as saved. */
    @PostMapping("/dishes")
    @ResponseStatus(HttpStatus.CREATED)
    DishSaved add(@RequestBody NewDish dish) {
        return service.add(dish.name(), dish.mealType(), dish.price());
    }
}
