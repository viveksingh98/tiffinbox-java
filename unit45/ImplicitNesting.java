class Plain { }

static class Marked { }

void main() {
    IO.println("Plain  isStatic: " + Modifier.isStatic(Plain.class.getModifiers()));
    IO.println("Marked isStatic: " + Modifier.isStatic(Marked.class.getModifiers()));
    IO.println("Plain  name    : " + Plain.class.getName());
    IO.println("Marked name    : " + Marked.class.getName());
    IO.println("this file      : " + getClass().getName());
}
