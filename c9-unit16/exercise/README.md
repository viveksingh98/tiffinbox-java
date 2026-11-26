# Course 9 · Unit 16 — the exercise

**Your turn:** this link builder fails on a final controller. Build the same link without a proxy, and keep the controller final.

`../after` is TiffinBox after this unit: `GET /api/v1/orders/{id}` answers one order as `HAL`, its `customer` link built by the Method
form on the final `CustomerReads`. `break.sh` rewrites that one link to the proxy form, `methodOn(CustomerReads.class)`, in a copy of
`../after`. Your job is to build the customer link again without a proxy, in `OrderResources.java` alone, and to leave `CustomerReads`
final.

```
cp -R ../after /tmp/u16-tree        # any copy; ../after itself is refused
sh break.sh /tmp/u16-tree
sh check.sh /tmp/u16-tree           # builds the copy offline, starts it alone on 21058 (H2), sends the requests itself
```

`check.sh` passes only when every clause holds: order 1 answers with its own link; its `customer` link ends `/api/v1/customers/Ravi`;
following it reads Ravi; `CustomerReads.java` is still `../after`'s final class; every other main file, the three poms and the spec equal
`../after`'s; and the code of `OrderResources.java` holds no `methodOn(CustomerReads` and does hold a `linkTo(` call with the `Method`
of `CustomerReads`. `OrderResourcesTest` stays red on the broken copy (`check.sh` builds with the tests skipped).

The broken copy, measured first on the route the exercise names (H2; host `127.0.0.1:<port>`; the receipts' `exercise` capture, every run):
the order route answers a server error with Boot's own body, and the JVM log holds Spring's proxy error for the final class.

What it prints:

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
GET /api/v1/orders/1 -> 500 application/json · type none · title Internal Server Error · detail none
following customer -> none · a body that is not JSON
the JVM log's exception: AopConfigException: Could not generate CGLIB subclass of class com.tiffinbox.web.CustomerReads: Common causes of this problem include using a final class or a n
FAIL clause 1: GET /api/v1/orders/1 does not answer 200 with its self link (got 500 application/json)
FAIL clause 2: the order has no customer link to /api/v1/customers/Ravi
FAIL clause 3: following customer does not answer Ravi (got none)
FAIL clause 6: OrderResources.java still proxies CustomerReads (methodOn(CustomerReads)
FAIL clause 6: no linkTo( call with CustomerReads' Method (the Method form)
check.sh: 5 clause(s) failed
```

Hint: the link builder can be handed the controller's class, the `Method` it maps and the arguments, and then it makes no proxy at all.
