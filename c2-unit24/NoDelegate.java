import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// The loader slide 5 warns about: loadClass overridden, local folder searched FIRST,
// no delegation to the parent. Point it at a hand-built java.lang.String and watch.
public class NoDelegate {

    static final class Rogue extends ClassLoader {
        private final Path dir;
        Rogue(Path dir, ClassLoader parent) { super("rogue", parent); this.dir = dir; }

        @Override public Class<?> loadClass(String n) throws ClassNotFoundException {
            Path f = dir.resolve(n.replace('.', '/') + ".class");
            if (Files.exists(f)) {
                System.out.println("  [rogue] found " + n + " locally — parent not asked");
                try {
                    byte[] b = Files.readAllBytes(f);
                    return defineClass(n, b, 0, b.length);
                } catch (IOException e) { throw new ClassNotFoundException(n, e); }
            }
            return super.loadClass(n);
        }
    }

    public static void main(String[] args) throws Exception {
        ClassLoader app = NoDelegate.class.getClassLoader();
        Class<?> c = new Rogue(Path.of("fake"), app).loadClass("java.lang.String");
        System.out.println("never printed: " + c);
    }
}
