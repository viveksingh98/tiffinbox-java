public class Boot {
    public static void main(String[] args) {
        for (int attempt = 1; attempt <= 2; attempt++) {
            try {
                System.out.println("attempt " + attempt + " -> limit " + Config.limit());
            } catch (Throwable t) {
                System.out.println("attempt " + attempt + " -> " + t);
                System.out.println("            caused by " + t.getCause());
            }
        }
    }
}
