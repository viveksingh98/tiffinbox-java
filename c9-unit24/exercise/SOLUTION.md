# Solution — Course 9 · unit 24

The handler `../after` ships, quoted from `../after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java` (`sh apply.sh
<your copy>` writes it over the broken method):

```java
    @GetMapping("/customers/{name}")
    ResponseEntity<ProblemDetail> customer(@PathVariable String name) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.GONE,
                "GET /customers/{name} is retired; its successor is GET /api/v1/customers/{name}");
        problem.setType(TiffinBoxErrors.ROUTE_RETIRED);
        problem.setTitle("Route retired");
        String successor = "/api/v1/customers/" + UriUtils.encodePathSegment(name, StandardCharsets.UTF_8);
        return ResponseEntity.status(HttpStatus.GONE)
                .header(HttpHeaders.LINK, "<" + successor + ">; rel=\"successor-version\"")
                .body(problem);
    }
```

The mapping, the method's name and so its `operationId` stay; the body stops reading the repository, so every name answers the same
`410`. The type is a constant beside the not-found type (`TiffinBoxErrors.ROUTE_RETIRED`), the `Link` names the successor for the name
asked, encoded as one path segment (`Meera Joshi` becomes `Meera%20Joshi`), and no `Deprecation` or `Sunset` date rides on the `410`:
those belong to the timeline's first step, the broken copy. `GET /api/v1/customers/{name}` is another class, `CustomerReads`, and is not
touched.

What it prints on the solved copy:

```
(1) GET /customers/Ravi -> 410 · application/problem+json · type route-retired
(2) GET /api/v1/customers/Ravi -> 200 · 67 B · md5 equal to after's: yes
(3) Link: </api/v1/customers/Ravi>; rel="successor-version"
(4) the files other than TiffinBoxServer.java byte-equal to ../after's: yes
PASS
```
