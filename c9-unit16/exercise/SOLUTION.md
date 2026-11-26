# Course 9 · Unit 16 — the solution

Build the `customer` link by the Method form: the controller's class, the `Method` it maps, the argument. No proxy is made, so
`CustomerReads` stays final. `apply.sh` writes exactly `../after`'s lines into a broken copy:

```
    private static final Method CUSTOMER_ONE;          // CustomerReads.one, looked up once by name
    ...
                linkTo(CustomerReads.class, CUSTOMER_ONE, order.customer()).withRel("customer"));
```

and drops the `throws java.sql.SQLException` the broken copy needed (the proxy form calls `CustomerReads.one`, which declares it).

```
sh break.sh /tmp/u16-tree && sh apply.sh /tmp/u16-tree && sh check.sh /tmp/u16-tree
```

The receipts run it under bash and under `/bin/zsh -f`, H2, on 21058, every run. Four refused variants fail it (run 1): `unfinal`
(`CustomerReads` made non-final: the proxy is made, and then fails on the customer record the handler returns - clause 4), `literal`
(the customer's address typed as a string: clause 6), `dropped` (the customer link removed: clause 2) and `fixedelsewhere` (another
main file touched: clause 5).

What it prints:

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
GET /api/v1/orders/1 -> 200 application/hal+json · links ['self=http://127.0.0.1:<port>/api/v1/orders/1', 'customer=http://127.0.0.1:<port>/api/v1/customers/Ravi']
following customer -> 200 application/json · name Ravi
the JVM log's exception: none
PASS - every clause holds
```
