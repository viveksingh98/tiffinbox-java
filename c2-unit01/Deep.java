int depth = 0;

void main() {
    try {
        dive();
    } catch (StackOverflowError e) {
        IO.println("stack overflowed after "
                 + depth + " calls");
    }
}

void dive() {
    depth++;
    dive();
}
