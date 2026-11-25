# The solution — unit 11

Remove the nickname line from the test's `responseFields`, and nothing else: the four members TiffinBox sends stay documented, the
status check stays ahead of the document call. On the broken copy:

```
sh apply.sh my-tiffinbox
sh check.sh my-tiffinbox
```

The solved test is the shipped one, byte for byte (the receipt prints both md5 values). The check then reads one passing test, the eight
snippets, `response-fields.adoc` listing exactly the members the wire carries, and the page:

What it prints
```
the test: tests 1 failures 0 errors 0 skipped 0
the snippets: 8 (curl-request.adoc,http-request.adoc,http-response.adoc,httpie-request.adoc,path-parameters.adoc,request-body.adoc,response-body.adoc,response-fields.adoc) · the build exit 0
response-fields.adoc lists name,mealsPerDay,pricePerMeal,mealType · the wire's body carries name,mealsPerDay,pricePerMeal,mealType · nickname appears 0 times (test, snippets, page)
PASS: TiffinBoxRestDocsTest ran and passed; the eight snippets; response-fields.adoc = the wire's members; the body = the wire's; the hand-written parts as ../after's
```
