# Your turn — unit 09

**Your turn:** document the four oh four on the public read only, and nowhere else.

Copy unit 08's frozen tree (this unit's `before`) and run the check on the copy: it builds the copy, starts TiffinBox alone on port
`20988` on H2, asks for the document and for a customer nobody has, stops it, and reads both.

```
cp -R ../before my-tiffinbox
sh check.sh my-tiffinbox
```

The public read is the operation that reads one customer by name under `/api/v1`. Document its not-found answer in the code, keep its
success answer, give the not-found answer Framework's problem schema, and write the committed document again from the running copy in
the same change. With nothing documented yet, the check fails like this:

What it prints
```
FAIL (clause 1): 0 operations document a four-oh-four, not the public read alone: none
```
