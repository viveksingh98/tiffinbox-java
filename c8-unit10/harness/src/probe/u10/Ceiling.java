package probe.u10;

import com.github.benmanes.caffeine.cache.Caffeine;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Pattern;

/**
 * Unit 10's ceiling: a harness on Caffeine's own API, not TiffinBox's cache - a plain main, no Spring, no database. args[0] is Course 2
 * unit 04's Bounded.java: its sequence (each cache.put("Name", n) and cache.get("Name"), in order), its ceiling (size() > n) and its
 * map's constructor are read off the file, never typed here. args[1] is the number of fresh pairs. Each pair, one JVM: Course 2's
 * LinkedHashMap in access order with removeEldestEntry, and a Caffeine cache with maximumSize(ceiling), a same-thread executor
 * (Runnable::run: its maintenance runs on the calling thread) and recordStats(); both fed the same sequence; cleanUp() on Caffeine
 * before reading. Prints, per map, the survivors and how many pairs printed them. Every line starts with CEILING.
 */
public final class Ceiling {
    private Ceiling() {}

    public static void main(String[] args) throws Exception {
        String src = Files.readString(Path.of(args[0]));
        int reps = Integer.parseInt(args[1]);
        var ctor = Pattern.compile("new LinkedHashMap<String, Integer>\\(([^)]*)\\)").matcher(src);
        var lim = Pattern.compile("return size\\(\\) > (\\d+);").matcher(src);
        if (!ctor.find() || !lim.find()) throw new IllegalStateException("Bounded.java moved: no map constructor or no ceiling");
        int ceiling = Integer.parseInt(lim.group(1));
        record Op(String verb, String name, Integer value) {}
        var ops = new ArrayList<Op>();
        var op = Pattern.compile("cache\\.(put|get)\\(\"(\\w+)\"(?:, (\\d+))?\\);").matcher(src);
        while (op.find()) ops.add(new Op(op.group(1), op.group(2), op.group(3) == null ? null : Integer.valueOf(op.group(3))));
        var seq = new ArrayList<String>();
        for (Op o : ops) seq.add(o.verb() + " " + o.name() + (o.value() == null ? "" : " " + o.value()));
        System.out.println("CEILING Bounded.java (read at run time): new LinkedHashMap<String, Integer>(" + ctor.group(1) + ") · the ceiling: size() > " + ceiling
                + " · the sequence " + seq + " · " + reps + " fresh pairs, one JVM - a harness on Caffeine's own API, not TiffinBox's cache");
        var lhm = new TreeMap<String, Integer>();
        var caf = new TreeMap<String, Integer>();
        var size = new TreeMap<Long, Integer>();
        var ev = new TreeMap<Long, Integer>();
        var lgone = new TreeMap<String, Integer>();
        var cgone = new TreeMap<String, Integer>();
        for (int r = 0; r < reps; r++) {
            var map = new LinkedHashMap<String, Integer>(16, 0.75f, true) {
                protected boolean removeEldestEntry(Map.Entry<String, Integer> e) {
                    return size() > ceiling;
                }
            };
            com.github.benmanes.caffeine.cache.Cache<String, Integer> c = Caffeine.newBuilder().maximumSize(ceiling).executor(Runnable::run).recordStats().build();
            var names = new TreeSet<String>();
            for (Op o : ops) {
                if (o.verb().equals("put")) {
                    map.put(o.name(), o.value());
                    c.put(o.name(), o.value());
                    names.add(o.name());
                } else {
                    map.get(o.name());
                    c.getIfPresent(o.name());
                }
            }
            c.cleanUp();
            lhm.merge(map.keySet().toString(), 1, Integer::sum);
            caf.merge(new TreeSet<>(c.asMap().keySet()).toString(), 1, Integer::sum);
            size.merge(c.estimatedSize(), 1, Integer::sum);
            ev.merge(c.stats().evictionCount(), 1, Integer::sum);
            var lg = new TreeSet<>(names); lg.removeAll(map.keySet());
            var cg = new TreeSet<>(names); cg.removeAll(c.asMap().keySet());
            lgone.merge(lg.toString(), 1, Integer::sum);
            cgone.merge(cg.toString(), 1, Integer::sum);
        }
        System.out.println("CEILING Course 2's LinkedHashMap (access order, removeEldestEntry): keySet() in its own order -> " + lhm + " · dropped " + lgone);
        System.out.println("CEILING Caffeine maximumSize(" + ceiling + "), executor(Runnable::run), cleanUp() before reading: asMap().keySet() sorted -> " + caf
                + " · dropped " + cgone + " · estimatedSize " + size + " · stats().evictionCount() " + ev);
        List<String> l = new ArrayList<>(lhm.keySet()), k = new ArrayList<>(caf.keySet());
        System.out.println("CEILING the same survivors: " + (l.equals(k) ? "yes" : "no"));
    }
}
