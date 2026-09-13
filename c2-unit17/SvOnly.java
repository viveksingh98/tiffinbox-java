static final ScopedValue<String> CURRENT_CUSTOMER = ScopedValue.newInstance();

void main() {
    ScopedValue.where(CURRENT_CUSTOMER, "Ravi")
               .run(() -> IO.println("current customer: " + CURRENT_CUSTOMER.get()));
    IO.println("bound outside? " + CURRENT_CUSTOMER.isBound());
}
