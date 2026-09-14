import java.util.List;
record Bad(String customer, List<String> meals) {
    Bad {
        this.meals = List.copyOf(meals);
    }
}
