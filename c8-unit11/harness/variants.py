"""Unit 11's harness copies, derived from the shipped files at run time - never a typed copy (python3 -I -B harness/variants.py NAME TREE).
TREE is a copy of after/; the variant NAME is written into it, and asserted to differ from its source by exactly the named lines (else
exit 1, nothing written). Each prints its removed and added lines (diff-style, < removed, > added):
  jdk      RedisCaching.java without its RedisCacheConfiguration bean (the @Bean method removed): Boot's own configuration applies -
           Java's serialization, Boot's default for Redis; the cache writer kept
  tolist   CustomerRepository.java's findAll back to Stream.toList() (the exercise's broken state; the json capture's contrast)
  strict   RedisCaching.java's serializer built strict: GenericJacksonJsonRedisSerializer.builder() with Spring's null-value support,
           the default typing RedisSerializer.json() uses, and Jackson's FAIL_ON_UNKNOWN_PROPERTIES enabled
  writer   RedisCaching.java without its RedisCacheManagerBuilderCustomizer bean: Boot's own cache writer, the one Boot builds over Lettuce
  ttlbean  RedisCaching.java's RedisCacheConfiguration bean built without CacheProperties: JSON values, nothing from spring.cache.redis.*
  compose  the anchor's compose.yaml as the receipts run it (TREE is the copy's folder; the file is compose.yaml there): project
           c8-unit11, both images by their digests with pull_policy: never, the ports 20503 (Redis) and 20504 (PostgreSQL)"""
import difflib, os, sys

name, tree = sys.argv[1], sys.argv[2]
RC = "tiffinbox-web/src/main/java/com/tiffinbox/web/RedisCaching.java"
CR = "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"
RED = "redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3"
PG = "postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873"

WRITER = """    /** Course 8, unit 11: the cache writer TiffinBox gives Redis - each write done before the call returns, under a lock. */
    @Bean
    RedisCacheManagerBuilderCustomizer immediateLockingWriter(RedisConnectionFactory connections) {
        return builder -> builder.cacheWriter(RedisCacheWriter.create(connections, writer -> writer.immediateWrites().enableLocking()));
    }

"""
CONF_HEAD = """    /** Course 8, unit 11: JSON values, and Boot's spring.cache.redis.* settings applied as Boot's own configuration applies them. */
    @Bean
    RedisCacheConfiguration redisCacheConfiguration(CacheProperties properties) {
"""
CONF = CONF_HEAD + """        CacheProperties.Redis redis = properties.getRedis();
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .serializeValuesWith(SerializationPair.fromSerializer(RedisSerializer.json()));
        if (redis.getTimeToLive() != null) {
            config = config.entryTtl(redis.getTimeToLive());
        }
        if (redis.getKeyPrefix() != null) {
            config = config.prefixCacheNameWith(redis.getKeyPrefix());
        }
        if (!redis.isCacheNullValues()) {
            config = config.disableCachingNullValues();
        }
        if (!redis.isUseKeyPrefix()) {
            config = config.disableKeyPrefix();
        }
        return config;
    }
"""
JSON = "                .serializeValuesWith(SerializationPair.fromSerializer(RedisSerializer.json()));\n"
STRICT = ("                .serializeValuesWith(SerializationPair.fromSerializer(org.springframework.data.redis.serializer.GenericJacksonJsonRedisSerializer.builder()\n"
          "                        .enableSpringCacheNullValueSupport().enableUnsafeDefaultTyping()\n"
          "                        .customize(b -> b.enable(tools.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)).build()));\n")
BARE = """    /** Course 8, unit 11: JSON values, and Boot's spring.cache.redis.* settings applied as Boot's own configuration applies them. */
    @Bean
    RedisCacheConfiguration redisCacheConfiguration(CacheProperties properties) {
        return RedisCacheConfiguration.defaultCacheConfig().serializeValuesWith(SerializationPair.fromSerializer(RedisSerializer.json()));
    }
"""
ARR = """        return customers.findAll(Sort.by("name")).stream().map(CustomerRepository::toRecord)
                .collect(Collectors.toCollection(ArrayList::new));
"""
TOL = """        return customers.findAll(Sort.by("name")).stream().map(CustomerRepository::toRecord).toList();
"""
COMPOSE = [('    image: postgres:18-alpine\n', '    image: %s\n    pull_policy: never\n' % PG),
           ('      - "127.0.0.1:18881:5432"\n', '      - "127.0.0.1:20504:5432"\n'),
           ('    image: redis:8-alpine\n', '    image: %s\n    pull_policy: never\n' % RED),
           ('      - "127.0.0.1:18882:6379"\n', '      - "127.0.0.1:20503:6379"\n'),
           ('name: tiffinbox-dev\n', 'name: c8-unit11\n')]
PLAN = {"jdk": (RC, [(CONF, "")]), "tolist": (CR, [(ARR, TOL)]), "strict": (RC, [(JSON, STRICT)]),
        "writer": (RC, [(WRITER, "")]), "ttlbean": (RC, [(CONF, BARE)]), "compose": ("compose.yaml", COMPOSE)}
if name not in PLAN:
    print("no variant %s" % name); sys.exit(1)
rel, edits = PLAN[name]
P = os.path.join(tree, rel)
src = open(P, encoding="utf-8").read()
dst = src
for old, new in edits:
    if dst.count(old) != 1:
        print("variant %s: the shipped lines moved (%r)" % (name, old.splitlines()[0])); sys.exit(1)
    dst = dst.replace(old, new)
want = []
for old, new in edits:
    want += ["-" + l for l in old.splitlines() if l not in new.splitlines()] + ["+" + l for l in new.splitlines() if l not in old.splitlines()]
d = [l for l in difflib.unified_diff(src.splitlines(), dst.splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
if sorted(d) != sorted(want):
    print("variant %s: its change is not the named one: %s" % (name, d)); sys.exit(1)
open(P, "w", encoding="utf-8").write(dst)
print("%s - from after/'s:" % rel)
for l in d:
    print("  %s %s" % ("<" if l[0] == "-" else ">", l[1:].strip()))
