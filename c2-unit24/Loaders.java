public class Loaders {
    static String who(ClassLoader cl) {
        return cl == null
            ? "null   <- the bootstrap loader, C++ inside the JVM"
            : cl.getName() + "   (" + cl.getClass().getName() + ")";
    }

    public static void main(String[] args) throws Exception {
        ClassLoader app = Loaders.class.getClassLoader();
        System.out.println("this class's loader       : " + who(app));
        System.out.println("  its parent              : " + who(app.getParent()));
        System.out.println("  its parent's parent     : " + who(app.getParent().getParent()));
        System.out.println("String.class loader       : " + who(String.class.getClassLoader()));
        System.out.println("ArrayList.class loader    : " + who(java.util.ArrayList.class.getClassLoader()));
        System.out.println("java.sql.Driver loader    : " + who(java.sql.Driver.class.getClassLoader()));
        System.out.println("javax.xml DocumentBuilder : " + who(javax.xml.parsers.DocumentBuilder.class.getClassLoader()));
        System.out.println("getSystemClassLoader()   == app    : " + (ClassLoader.getSystemClassLoader() == app));
        System.out.println("getPlatformClassLoader() == parent : " + (ClassLoader.getPlatformClassLoader() == app.getParent()));
        System.out.println("String's module          : " + String.class.getModule().getName());
        System.out.println("java.sql.Driver's module : " + java.sql.Driver.class.getModule().getName());
        System.out.println("Loaders' module          : " + Loaders.class.getModule().getName() + "  (an unnamed module)");
    }
}
