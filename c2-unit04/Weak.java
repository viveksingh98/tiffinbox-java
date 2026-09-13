import java.lang.ref.SoftReference;
import java.lang.ref.WeakReference;

void main() {
    var bill = new StringBuilder("Ravi: 7200");
    var weak = new WeakReference<>(bill);
    var soft = new SoftReference<>(new StringBuilder("Priya: 3600"));

    IO.println("weak before:   " + weak.get());
    bill = null;
    System.gc();
    IO.println("weak after gc: " + weak.get());
    IO.println("soft after gc: " + soft.get());
}
