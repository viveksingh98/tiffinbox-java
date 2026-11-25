# Your turn — unit 11

**Your turn:** this test documents a nickname TiffinBox never sends. Make it pass without the nickname.

Copy unit 11's frozen tree (this unit's `after`), break the copy with `break.sh` (it adds one documented member, `nickname`, to
`TiffinBoxRestDocsTest`'s `responseFields`), and run the check on it: the check builds the web module and what it needs with the one
REST Docs test run, so the snippets are written and the page step is reached; starts TiffinBox alone on port `21008` on H2, asks for
Ravi, and stops it.

```
cp -R ../after my-tiffinbox
sh break.sh my-tiffinbox
sh check.sh my-tiffinbox
```

The test documents what the answer carries, and the answer is right. Fix the test, not the answer and not the snippets: the build
writes the snippets again, and deleting every field, marking the nickname optional or switching the test off does not pass the check.
With the test still broken, the check fails like this:

What it prints
```
the test: tests 1 failures 0 errors 1 skipped 0 · error org.springframework.restdocs.snippet.SnippetException: Fields with the following paths were not found in the payload: [nickname]
the snippets: 6 (curl-request.adoc,http-request.adoc,http-response.adoc,httpie-request.adoc,request-body.adoc,response-body.adoc) · the build exit 1
FAIL (clause 1): the build did not pass with TiffinBoxRestDocsTest run, passing and not skipped
```
