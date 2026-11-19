package probe.u16;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.Range;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.RedisStreamCommands.XAddOptions;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.connection.stream.Consumer;
import org.springframework.data.redis.connection.stream.MapRecord;
import org.springframework.data.redis.connection.stream.PendingMessage;
import org.springframework.data.redis.connection.stream.PendingMessagesSummary;
import org.springframework.data.redis.connection.stream.ReadOffset;
import org.springframework.data.redis.connection.stream.RecordId;
import org.springframework.data.redis.connection.stream.StreamOffset;
import org.springframework.data.redis.connection.stream.StreamReadOptions;
import org.springframework.data.redis.connection.stream.StreamRecords;
import org.springframework.data.redis.core.StreamOperations;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.listener.ChannelTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.stream.StreamMessageListenerContainer;
import org.springframework.data.redis.stream.Subscription;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.TreeMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Unit 16's Redis harness: Pub/Sub, the consumer group, the claim, the listener container and the trim - the harness's, never
 * TiffinBox's (⚑7). A small Spring context: Lettuce's connection factory on 127.0.0.1:&lt;h16.port&gt; and a StringRedisTemplate,
 * nothing else - no TiffinBox start, no web server, no database. The stream key is the anchor's (tiffinbox:kitchen-events, the group
 * kitchen); the entries the harness writes are its own (type harness-entry, names entry-1 ... entry-10), written from a LinkedHashMap
 * in the anchor's field order. Every id it prints has its time part written &lt;t&gt; (an id Redis gives it, whose first part is a time).
 * args[0] is a comma-separated list of steps; every line it prints starts with PROBE:
 *   pub=MSG   convertAndSend on the channel tiffinbox:kitchen: the receivers Redis counted
 *   sub=N     a RedisMessageListenerContainer on ChannelTopic tiffinbox:kitchen; a pause (the receipt publishes, or not); then the
 *             messages it heard, read until N are in its list (a count, cap 200 reads); then the container stopped and its listening
 *             polled to false before the factory closes
 *   add10     ten XADDs on tiffinbox:kitchen-events (the harness's entries)
 *   c1        consumer c1 of the group kitchen: read up to 5 (lastConsumed, i.e. ">"), acknowledge the first 2, then the harness holds
 *             (a pause the receipt answers with SIGINT - the planted hold, exit 130)
 *   c2        the pending list by Java (the summary, per consumer), c1's pending ids, claimed by c2 (min-idle-time Duration.ZERO),
 *             acknowledged, the summary again
 *   c3        a StreamMessageListenerContainer, consumer c3 (lastConsumed, no auto-ack; the listener acknowledges each), an ECHO marker
 *             before it starts; the entries read until 5 are acknowledged (a count, cap 400 reads); the container stopped, its
 *             subscription polled to inactive, an ECHO marker - and only then the factory closes (R.410)
 *   trim      a thousand XADDs on tiffinbox:kitchen-events with XAddOptions.maxlen(100).approximateTrimming(true) (MAXLEN ~ 100)
 *   xlen      opsForStream().size (XLEN), Java's
 *   pause     the receipt reads now (redis-cli), then writes ./go
 */
public final class H16 {
    private H16() {}

    static final String CHANNEL = "tiffinbox:kitchen";
    static final String KEY = "tiffinbox:kitchen-events";
    static final String GROUP = "kitchen";
    static AnnotationConfigApplicationContext ctx;

    @Configuration(proxyBeanMethods = false)
    static class Conn {
        @Bean
        LettuceConnectionFactory redisConnectionFactory() {
            return new LettuceConnectionFactory(new RedisStandaloneConfiguration("127.0.0.1", Integer.getInteger("h16.port")));
        }

        @Bean
        StringRedisTemplate stringRedisTemplate(RedisConnectionFactory cf) {
            return new StringRedisTemplate(cf);
        }
    }

    public static void main(String[] args) throws Exception {
        // Logback's default layout (every exception's class and stack printed), the root at WARN: an ERROR is never hidden (R.410)
        ((ch.qos.logback.classic.Logger) org.slf4j.LoggerFactory.getLogger("ROOT")).setLevel(ch.qos.logback.classic.Level.WARN);
        ctx = new AnnotationConfigApplicationContext(Conn.class);
        int code = 0;
        try {
            for (String s : args[0].split(",")) step(s);
        } catch (Throwable t) {
            code = 1;
            p("a step threw: " + t.getClass().getName() + ": " + first(t.getMessage()));
        }
        ctx.close();
        System.out.println("PROBE <<< exit " + code);
        System.exit(code);
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    static String first(String m) {
        if (m == null) return "null";
        String s = m.split("\n")[0];
        return s.length() > 240 ? s.substring(0, 240) + "…" : s;
    }

    static StringRedisTemplate t() {
        return ctx.getBean(StringRedisTemplate.class);
    }

    static StreamOperations<String, Object, Object> ops() {
        return t().opsForStream();
    }

    static String id(RecordId id) {
        return id.getValue().replaceFirst("^[0-9]+-", "<t>-");
    }

    static String ids(List<? extends MapRecord<String, ?, ?>> rs) {
        var out = new ArrayList<String>();
        for (var r : rs) out.add(id(r.getId()));
        return out.toString();
    }

    static void echo(String marker) {
        try (var c = ctx.getBean(RedisConnectionFactory.class).getConnection()) {
            c.echo(marker.getBytes(StandardCharsets.UTF_8));
        }
    }

    static void step(String s) throws Exception {
        if (s.startsWith("pub=")) { pub(s.substring(4)); return; }
        if (s.startsWith("sub=")) { sub(Integer.parseInt(s.substring(4))); return; }
        switch (s) {
            case "add10" -> add10();
            case "c1" -> c1();
            case "c2" -> c2();
            case "c3" -> c3();
            case "trim" -> trim();
            case "xlen" -> p("xlen (Java, opsForStream().size): " + ops().size(KEY));
            case "pause" -> pause();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static int pauses = 0;

    static void pause() throws Exception {
        // the receipt runs redis-cli while this JVM is up, then writes ./go (no time is measured)
        Path go = Path.of("go");
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        System.out.flush();
        for (int i = 0; i < 2400 && !Files.exists(go); i++) Thread.sleep(50);
        p("pause " + pauses + ": resumed " + (Files.exists(go) ? "by the receipt" : "without the receipt's go"));
        Files.deleteIfExists(go);
    }

    static void pub(String msg) {
        p("publisher (the harness's, convertAndSend on " + CHANNEL + "): " + msg + " -> receivers " + t().convertAndSend(CHANNEL, msg));
    }

    static void sub(int want) throws Exception {
        var heard = new CopyOnWriteArrayList<String>();
        var c = new RedisMessageListenerContainer();
        c.setConnectionFactory(ctx.getBean(RedisConnectionFactory.class));
        c.addMessageListener((m, pattern) -> heard.add(new String(m.getBody(), StandardCharsets.UTF_8)), new ChannelTopic(CHANNEL));
        c.afterPropertiesSet();
        c.start();
        int i = 0;
        while (!c.isListening() && i < 200) { Thread.sleep(50); i++; }
        p("subscriber (the harness's, a RedisMessageListenerContainer on ChannelTopic " + CHANNEL + "): listening " + c.isListening() + " · heard so far " + heard.size());
        pause();
        i = 0;
        while (heard.size() < want && i < 200) { Thread.sleep(50); i++; }
        p("subscriber: heard " + heard.size() + " " + heard);
        c.stop();
        i = 0;
        while ((c.isRunning() || c.isListening()) && i < 200) { Thread.sleep(50); i++; }
        p("subscriber: the container stopped - isRunning " + c.isRunning() + " · isListening " + c.isListening() + " (polled to false before the factory closes)");
        c.destroy();
    }

    static LinkedHashMap<String, String> fields(int n) {
        var f = new LinkedHashMap<String, String>();
        f.put("type", "harness-entry");
        f.put("name", "entry-" + n);
        f.put("mealType", List.of("VEG", "NON_VEG", "VEGAN").get((n - 1) % 3));
        return f;
    }

    static void add10() {
        var out = new ArrayList<String>();
        for (int n = 1; n <= 10; n++) out.add(id(ops().add(StreamRecords.mapBacked(fields(n)).withStreamKey(KEY))));
        p("add10 (the harness's entries, ten XADDs, a LinkedHashMap each): ids " + out + " · XLEN by Java " + ops().size(KEY));
    }

    static void c1() throws Exception {
        List<MapRecord<String, Object, Object>> r = ops().read(Consumer.from(GROUP, "c1"), StreamReadOptions.empty().count(5),
                StreamOffset.create(KEY, ReadOffset.lastConsumed()));
        long acked = ops().acknowledge(KEY, GROUP, r.get(0).getId(), r.get(1).getId());
        p("c1 (the harness's consumer, group " + GROUP + "): read " + r.size() + " " + ids(r) + " · acknowledged " + acked + " [" + id(r.get(0).getId()) + ", " + id(r.get(1).getId()) + "]");
        // the planted hold: the receipt answers this pause with SIGINT, never with ./go
        p("hold (the harness holds c1, mid-batch, planted): pid " + ProcessHandle.current().pid());
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        System.out.flush();
        for (int i = 0; i < 2400; i++) Thread.sleep(50);
        p("hold: no SIGINT came");
    }

    static String summary(PendingMessagesSummary s) {
        return "total " + s.getTotalPendingMessages() + " · per consumer " + new TreeMap<>(s.getPendingMessagesPerConsumer());
    }

    static void c2() {
        p("c2 (the harness's consumer): the pending list by Java before the claim: " + summary(ops().pending(KEY, GROUP)));
        var pend = ops().pending(KEY, Consumer.from(GROUP, "c1"), Range.unbounded(), 10);
        var pids = new ArrayList<RecordId>();
        for (PendingMessage m : pend) pids.add(m.getId());
        List<MapRecord<String, Object, Object>> claimed = ops().claim(KEY, GROUP, "c2", Duration.ZERO, pids.toArray(new RecordId[0]));
        long acked = ops().acknowledge(KEY, GROUP, pids.toArray(new RecordId[0]));
        p("c2: c1's pending ids " + pend.size() + " · claimed " + claimed.size() + " " + ids(claimed) + " (min-idle-time Duration.ZERO) · acknowledged " + acked);
        p("c2: the pending list by Java after: " + summary(ops().pending(KEY, GROUP)) + " · XLEN by Java " + ops().size(KEY));
    }

    static void c3() throws Exception {
        var cf = ctx.getBean(RedisConnectionFactory.class);
        var options = StreamMessageListenerContainer.StreamMessageListenerContainerOptions.builder().pollTimeout(Duration.ofMillis(100)).build();
        StreamMessageListenerContainer<String, MapRecord<String, String, String>> c = StreamMessageListenerContainer.create(cf, options);
        var got = new CopyOnWriteArrayList<String>();
        var acked = new AtomicInteger();
        echo("h16:c3-start");
        Subscription sub = c.receive(Consumer.from(GROUP, "c3"), StreamOffset.create(KEY, ReadOffset.lastConsumed()), m -> {
            got.add(m.getValue().get("name"));
            acked.addAndGet(t().opsForStream().acknowledge(GROUP, m).intValue());
        });
        c.start();
        int i = 0;
        while (acked.get() < 5 && i < 400) { Thread.sleep(50); i++; }
        c.stop();
        int k = 0;
        while (sub.isActive() && k < 400) { Thread.sleep(50); k++; }
        echo("h16:c3-end");
        p("c3 (the harness's StreamMessageListenerContainer, consumer c3, no auto-ack, the listener acknowledges each): received " + got.size() + " " + got + " · acknowledged " + acked.get());
        p("c3: the container stopped, its subscription polled to inactive (isActive " + sub.isActive() + ", running " + c.isRunning() + ") - then the factory closes");
        p("c3: the pending list by Java after: " + summary(ops().pending(KEY, GROUP)) + " · XLEN by Java " + ops().size(KEY));
    }

    static void trim() {
        var opt = XAddOptions.maxlen(100).approximateTrimming(true);
        for (int n = 1; n <= 1000; n++) {
            var f = new LinkedHashMap<String, String>();   // the same three fields, short values: a node holds a hundred entries by count
            f.put("type", "harness-entry");
            f.put("name", "t" + n);
            f.put("mealType", "VEG");
            ops().add(StreamRecords.mapBacked(f).withStreamKey(KEY), opt);
        }
        p("trim (the harness's entries, a thousand XADDs, XAddOptions.maxlen(100).approximateTrimming(true): MAXLEN ~ 100): XLEN by Java " + ops().size(KEY));
    }
}
