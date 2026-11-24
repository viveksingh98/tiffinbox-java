# Unit 07 exercise — make the spec require what the wire requires

**Your turn:** the spec says meals are optional. Make the spec require them, then check it against the wire.

TiffinBox's own document (`/v3/api-docs`) lists two of `Customer`'s four properties as required; the server refuses a new customer
that leaves out any one of the four. Copy this unit's `after/` (never edit `after/` itself), change your copy, and run the check from
this folder:

```bash
cp -R ../after ../my-tiffinbox
PORT=20968 sh check.sh ../my-tiffinbox
```

`check.sh` removes its saved files first, builds your copy (its tests included), starts its jar alone, reads the document and sends
five new customers - one with every property, four that each leave one out. It passes only when (1) the served document requires all
four, (2) the committed copy of the document (`tiffinbox-web/src/test/resources/openapi/tiffinbox.json`) equals the served one and
`OpenApiSpecTest` passed, and (3) the server still refuses the four and takes the full one. It names each clause your copy breaks.

What it prints (your copy as shipped):

```
FAIL (clause 1): required mealType/name · the committed file = the served document, the test passed · the five POSTs 400 400 400 400 201
```

The measured solution, as one script: `SOLUTION.md`.
