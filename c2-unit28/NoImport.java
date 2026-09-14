void main() {
    var client = HttpClient.newHttpClient();
}
// Does NOT compile, on purpose. A compact source file imports java.base for free —
// and HttpClient lives in a different module. Fix: import module java.net.http;
