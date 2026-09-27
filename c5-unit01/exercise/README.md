# Exercise — let Boot read the port

`TiffinBoxServer.main` still starts with Course 4's bridge: it copies a positional argument into the system property
`tiffinbox.port`, so that `java -jar tiffinbox-web-1.0.0.jar 18431` kept working. Boot reads its own command line now.

**Delete those three lines** and run the server with Boot's form instead:

```
rsync -a --exclude target ../../c5-tiffinbox/ my-tiffinbox/
# edit my-tiffinbox/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
(cd my-tiffinbox && mvn -q -Dmaven.repo.local=../../.m2-demo -DskipTests package)
java -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
../../c4-unit31/curlset.sh 18431 | grep ' -> ' | md5 -q
```

Done means: the seven responses still hash to `115c36bac276128e245ca57df11c2891`. Then run the OLD command,
`java -jar … 18431`, and say which port the server listens on, and why nothing warned you. Solution in `solution/`.
