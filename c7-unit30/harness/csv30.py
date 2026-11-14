"""The import's file (python3 -I harness/csv30.py N): a header line, then N customers "Customer 0000001" ..., meals a day 1-3, a price
of 100, meal types cycling - unit 20's generator, as CustomerImport's lines name,mealsPerDay,pricePerMeal,mealType."""
import sys

print("name,mealsPerDay,pricePerMeal,mealType")
for i in range(1, int(sys.argv[1]) + 1):
    print("Customer %07d,%d,100,%s" % (i, 1 + i % 3, ["VEG", "NON_VEG", "VEGAN"][i % 3]))
