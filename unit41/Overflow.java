void main() {
    IO.println("int max:  " + Integer.MAX_VALUE);
    IO.println("int min:  " + Integer.MIN_VALUE);
    IO.println("one more: " + (Integer.MAX_VALUE + 1));

    int paisePerKitchen = 2_082_000;
    int kitchens = 1200;
    IO.println("int  total paise: " + paisePerKitchen * kitchens);
    IO.println("long total paise: " + (long) paisePerKitchen * kitchens);
    IO.println("cast too late   : " + (long) (paisePerKitchen * kitchens));

    IO.println("long max: " + Long.MAX_VALUE);
    long big = 3_000_000_000L;
    IO.println("with the L suffix: " + big);
}
