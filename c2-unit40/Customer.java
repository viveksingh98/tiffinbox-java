public record Customer(
        @NotBlank String name,
        @Range(min = 1, max = 5) int mealsPerDay,
        @Range(min = 50, max = 500) int pricePerMeal,
        boolean isVeg) { }
