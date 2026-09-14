public class Config {
    static final int LIMIT =
        Integer.parseInt(System.getProperty("tiffinbox.limit", "not-a-number"));

    static int limit() { return LIMIT; }
}
