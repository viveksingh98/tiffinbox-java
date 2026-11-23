"""Unit 21's labelled copies of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no secrets/),
then the lines below changed, and the change printed as a unified diff. Each is labelled wherever it prints: a copy is never the
anchor's (R.392).
  std        dish-settings.json's analyzer "dish" without its synonym filter - the standard tokenizer and lowercase, the steps of
             Elasticsearch's own standard analyzer: "a copy with the standard analyzer" (nohit; its index on 20605 serves sayso, fuzzy)
  healthkey  application.yaml without the seven Elasticsearch names in its exclude list, and management.health.elasticsearch.enabled:
             false in their place - the health key alone, the refused shape (default)
  nolists    the two ITs' migration lists back to V1-V3 (a plant: V4 without them fails two tests)
  nobind     ElasticsearchIT without its 127.0.0.1:20606 binding (a plant: the port on every interface)"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
S = "tiffinbox-web/src/main/resources/dish-settings.json"
Y = "tiffinbox-web/src/main/resources/application.yaml"
T = "tiffinbox-web/src/test/java/com/tiffinbox/"
ES7 = "".join("      - org.springframework.boot." + c + "\n" for c in (
    "elasticsearch.autoconfigure.ElasticsearchClientAutoConfiguration", "elasticsearch.autoconfigure.ElasticsearchRestClientAutoConfiguration",
    "elasticsearch.autoconfigure.health.ElasticsearchRestHealthContributorAutoConfiguration", "data.elasticsearch.autoconfigure.DataElasticsearchAutoConfiguration",
    "data.elasticsearch.autoconfigure.DataElasticsearchReactiveRepositoriesAutoConfiguration", "data.elasticsearch.autoconfigure.DataElasticsearchRepositoriesAutoConfiguration",
    "data.elasticsearch.autoconfigure.health.DataElasticsearchReactiveHealthContributorAutoConfiguration"))
F = {"std": [(S, '"filter": ["lowercase", "veg_syn"]', '"filter": ["lowercase"]')],
     "healthkey": [(Y, ES7, ""), (Y, "  health:\n    redis:\n      enabled: false\n", "  health:\n    redis:\n      enabled: false\n    elasticsearch:\n      enabled: false\n")],
     "nolists": [(T + "jdbc/CustomerAggregatesIT.java", '"3 true", "4 true");', '"3 true");'),
                 (T + "CustomerEntityRepositoryIT.java", '"3 customer audit columns true", "4 dish true");', '"3 customer audit columns true");')],
     "nobind": [(T + "web/ElasticsearchIT.java", """            .withExposedPorts(9200)
            .withCreateContainerCmdModifier(cmd -> cmd.getHostConfig().withPortBindings(
                    new PortBinding(Ports.Binding.bindIpAndPort("127.0.0.1", 20606), new ExposedPort(9200))));""", """            .withExposedPorts(9200);""")]}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
for f, old, new in F:
    p = os.path.join(OUT, f); s = open(p, encoding="utf-8").read()
    if s.count(old) != 1: print("FAIL the lines to change are not in " + f + " once"); sys.exit(1)
    t = s.replace(old, new)
    open(p, "w", encoding="utf-8").write(t)
    d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + f, NAME + "/" + f, lineterm="", n=0) if not l.startswith("@@")]
    print("\n".join(d))
