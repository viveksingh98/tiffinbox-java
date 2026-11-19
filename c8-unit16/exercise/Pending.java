import org.springframework.data.domain.Range;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.connection.stream.Consumer;
import org.springframework.data.redis.connection.stream.MapRecord;
import org.springframework.data.redis.connection.stream.PendingMessage;
import org.springframework.data.redis.connection.stream.ReadOffset;
import org.springframework.data.redis.connection.stream.RecordId;
import org.springframework.data.redis.connection.stream.StreamOffset;
import org.springframework.data.redis.connection.stream.StreamReadOptions;
import org.springframework.data.redis.connection.stream.StreamRecords;
import org.springframework.data.redis.core.StreamOperations;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.TreeMap;

/**
 * Unit 16's exercise: the kitchen's events on Redis, a stream and a consumer group, through Spring Data Redis's StringRedisTemplate on
 * the anchor's libraries - no TiffinBox, no database, no Spring context: Lettuce's connection factory, built here. One program, three
 * roles (args: Redis's port on 127.0.0.1, the role):
 *   died   five kitchen events added to tiffinbox:kitchen-events (a LinkedHashMap each: type, name, mealType), the group kitchen
 *          created from the stream's first entry, then consumer c1 reads all five, acknowledges two and exits - it never acknowledges
 *          the other three: the consumer that died
 *   read   consumer c2 reads the group with ">" - the entries no consumer of the group has been given yet
 *   claim  consumer c2 takes c1's pending entries (XCLAIM, a min-idle-time of Duration.ZERO) and acknowledges them
 * Each role prints what Java read, and the group's pending list as Java reads it (XPENDING's summary).
 */
public class Pending {
    static final String KEY = "tiffinbox:kitchen-events";
    static final String GROUP = "kitchen";

    public static void main(String[] args) {
        ((ch.qos.logback.classic.Logger) org.slf4j.LoggerFactory.getLogger("ROOT")).setLevel(ch.qos.logback.classic.Level.WARN);
        var cf = new LettuceConnectionFactory(new RedisStandaloneConfiguration("127.0.0.1", Integer.parseInt(args[0])));
        cf.afterPropertiesSet();
        cf.start();
        StreamOperations<String, Object, Object> ops = new StringRedisTemplate(cf).opsForStream();
        switch (args[1]) {
            case "died" -> {
                String[][] events = {{"Asha", "VEGAN"}, {"Kiran", "VEG"}, {"Leela", "NON_VEG"}, {"Omar", "VEG"}, {"Tara", "VEGAN"}};
                for (String[] e : events) {
                    var f = new LinkedHashMap<String, String>();
                    f.put("type", "customer-added");
                    f.put("name", e[0]);
                    f.put("mealType", e[1]);
                    ops.add(StreamRecords.mapBacked(f).withStreamKey(KEY));
                }
                ops.createGroup(KEY, ReadOffset.from("0-0"), GROUP);
                List<MapRecord<String, Object, Object>> r = ops.read(Consumer.from(GROUP, "c1"), StreamReadOptions.empty().count(10),
                        StreamOffset.create(KEY, ReadOffset.lastConsumed()));
                long acked = ops.acknowledge(KEY, GROUP, r.get(0).getId(), r.get(1).getId());
                System.out.println("events added: " + ops.size(KEY) + " · c1 read " + r.size() + " · acknowledged " + acked + " · then c1 stops");
            }
            case "read" -> {
                List<MapRecord<String, Object, Object>> r = ops.read(Consumer.from(GROUP, "c2"), StreamReadOptions.empty().count(10),
                        StreamOffset.create(KEY, ReadOffset.lastConsumed()));
                long acked = r.isEmpty() ? 0 : ops.acknowledge(KEY, GROUP, r.stream().map(MapRecord::getId).toArray(RecordId[]::new));
                System.out.println("c2 read " + r.size() + " new entries (\">\") · acknowledged " + acked);
            }
            case "claim" -> {
                var ids = new ArrayList<RecordId>();
                for (PendingMessage m : ops.pending(KEY, Consumer.from(GROUP, "c1"), Range.unbounded(), 10)) ids.add(m.getId());
                List<MapRecord<String, Object, Object>> r = ops.claim(KEY, GROUP, "c2", Duration.ZERO, ids.toArray(RecordId[]::new));
                long acked = r.isEmpty() ? 0 : ops.acknowledge(KEY, GROUP, r.stream().map(MapRecord::getId).toArray(RecordId[]::new));
                System.out.println("c2 claimed " + r.size() + " of c1's pending entries · acknowledged " + acked);
            }
            default -> throw new IllegalArgumentException("died, read or claim");
        }
        var s = ops.pending(KEY, GROUP);
        System.out.println("the pending list, by Java: " + s.getTotalPendingMessages() + " · per consumer " + new TreeMap<>(s.getPendingMessagesPerConsumer()));
        cf.destroy();
    }
}
