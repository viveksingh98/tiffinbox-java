# Solution: count the not-founds by route

What it prints (the solved answer):
```
PASS: 3 404 rows counted by uri, and the not-a-route line names the catch-all pattern
```

The answer:
```
/** 3
/api/v1/customers/{name} 2
/api/v1/customers/{name}/bill 1
not a route: /**
```
