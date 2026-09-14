import com.fasterxml.jackson.annotation.JsonProperty;

/** The customer record from the Jackson unit, annotation included: the record
 *  component is isVeg, and the app's JSON has always called the flag "veg". */
public record Customer(String name,
                       int mealsPerDay,
                       int pricePerMeal,
                       @JsonProperty("veg") boolean isVeg) {
    public int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}
