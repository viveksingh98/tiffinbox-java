import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;

public class Plugins {

    static final class FolderLoader extends ClassLoader {
        private final Path dir;
        FolderLoader(String name, Path dir, ClassLoader parent) {
            super(name, parent);   this.dir = dir;
        }
        @Override protected Class<?> findClass(String n) throws ClassNotFoundException {
            try {
                byte[] b = Files.readAllBytes(dir.resolve(n + ".class"));
                System.out.printf("  [%s] read %d bytes, magic = 0x%08X%n", getName(), b.length, ByteBuffer.wrap(b).getInt());
                return defineClass(n, b, 0, b.length);
            } catch (IOException e) { throw new ClassNotFoundException(n, e); }
        }
    }

    public static void main(String[] args) throws Exception {
        Path dir = Path.of(args[0]);
        ClassLoader app = Plugins.class.getClassLoader();

        boolean onCp = true;
        try { Class.forName("SeasonalMenu"); } catch (ClassNotFoundException e) { onCp = false; }
        System.out.println("on the class path? " + onCp);

        Class<?> c1 = new FolderLoader("plugin-1", dir, app).loadClass("SeasonalMenu");
        Special s = (Special) c1.getDeclaredConstructor().newInstance();
        System.out.println("describe()         : " + s.describe());
        System.out.println("SeasonalMenu loader: " + c1.getClassLoader().getName());
        System.out.println("Special loader     : " + Special.class.getClassLoader().getName() + "  <- the parent defined the interface");
        System.out.println("delegation check   : String loaded by " + c1.getClassLoader().loadClass("java.lang.String").getClassLoader());

        Class<?> c2 = new FolderLoader("plugin-2", dir, app).loadClass("SeasonalMenu");
        Object other = c2.getDeclaredConstructor().newInstance();
        System.out.println("same name          : " + c1.getName().equals(c2.getName()));
        System.out.println("same Class object  : " + (c1 == c2));
        try {
            c1.cast(other);
        } catch (ClassCastException e) {
            System.out.println("cast across loaders: ClassCastException: " + e.getMessage());
        }
    }
}
