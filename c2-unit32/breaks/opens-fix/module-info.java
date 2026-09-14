module tiffinbox.api {
    requires transitive java.net.http;
    exports com.tiffinbox.api;
    opens com.tiffinbox.api to tiffinbox.app;
}
