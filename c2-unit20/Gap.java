record One(String a) {}
record Two(String a, int b) {}
record Three(String a, int b, boolean c) {}
record Four(String a, int b, boolean c, long d) {}
void main() {
    var o = new One("Ravi");
    var t = new Two("Ravi", 2);
    var h = new Three("Ravi", 2, true);
    var f = new Four("Ravi", 2, true, 7200L);
    row("1 component ", o.hashCode(), Objects.hash("Ravi"));
    row("2 components", t.hashCode(), Objects.hash("Ravi", 2));
    row("3 components", h.hashCode(), Objects.hash("Ravi", 2, true));
    row("4 components", f.hashCode(), Objects.hash("Ravi", 2, true, 7200L));
    IO.println("");
    IO.println("31^1=" + 31 + "  31^2=" + 31*31 + "  31^3=" + 31*31*31 + "  31^4=" + 31*31*31*31);
}
static void row(String label, int rec, int objHash) {
    IO.println(label + " : record " + rec + "   Objects.hash " + objHash + "   gap " + (objHash - rec));
}
