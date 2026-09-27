# Exercise — no pin at all

`../../c5-tiffinbox/pom.xml` moves the Jackson 2 family with one property, `<jackson-2-bom.version>2.22.2</jackson-2-bom.version>`.
**Delete that line** and rebuild clean. Predict first: split family again, or one version?

```
rsync -a --exclude target ../../c5-tiffinbox/ my-tiffinbox/
# delete the <jackson-2-bom.version> line from my-tiffinbox/pom.xml
(cd my-tiffinbox && mvn -q -Dmaven.repo.local=../../.m2-demo -DskipTests clean package)
ls my-tiffinbox/tiffinbox-web/target/lib | grep jackson
```

Done means: you can name the three versions, say who chose them, and say why this is not the split family of the break.
Then serve it and check the seven answers (`../../c4-unit31/curlset.sh`). Solution in `solution/`.
