package com.tiffinbox.web;

import com.tiffinbox.MealType;
import com.tiffinbox.OrderEntity;
import com.tiffinbox.OrderEntityRepository;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.KeysetScrollPosition;
import org.springframework.data.domain.Limit;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Window;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.ErrorResponseException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * Course 9, unit 13: the order list, GET /api/v1/orders - TiffinBox's first route that pages. It pages by a cursor over Spring Data's
 * keyset (Course 7's Window, ScrollPosition.keyset() and KeysetScrollPosition, through OrderEntityRepository): the answer is
 * {"items": [...], "next": <cursor or null>}, and the next page is the same request with ?cursor= set to that next. The cursor says
 * where the next page starts - the sort's values and the id of the last order read - and it is signed, not hidden: its first half is
 * base64url of a readable JSON payload {"s": sort, "f": mealType or JSON null, "k": the keyset's keys with their types}, its second
 * half an HMAC-SHA256 of the first under this start's key. A cursor is bound to its sort and its filter: reused with another, it is
 * refused, and the refusal names the parameter that differs.
 *
 * <p>It sorts by a whitelist only (newest, oldest, amount, customer); it filters by mealType only, by TiffinBox's own meal types; it
 * refuses what it does not know - an unknown sort, parameter or meal type, a cursor it did not sign or one written for another
 * request, a page size outside 1 to 50 - each a four hundred with its own problem type (tag:tiffinbox.example,2026:...). The id is
 * the tie-breaker: Spring Data adds it to the ORDER BY and the WHERE (two orders share every placed_at in V6's rows).
 *
 * <p>What it does NOT do: no offset (no page number, no skipped rows); no write - no public route adds an order (the receipts' insert
 * is the harness's); no key chosen by a client - the key is the setting tiffinbox.cursor-key, or, unset, 32 random bytes made at each
 * start, so a cursor from before a restart is refused; nothing about a row deleted between two pages (never measured).
 *
 * <p>final, as CustomerReads is: no proxy is made of it (a CGLIB proxy cannot subclass a final class - a later unit's concern).
 */
@RestController
final class OrderPages {

    private static final System.Logger LOG = System.getLogger("tiffinbox");
    private static final String TYPE = "tag:tiffinbox.example,2026:";

    /** The sorts a client may ask for, by name - the only ones: a client never names a column. */
    static final Map<String, Sort> SORTS = new LinkedHashMap<>();
    static {
        SORTS.put("newest", Sort.by(Sort.Direction.DESC, "placedAt"));
        SORTS.put("oldest", Sort.by(Sort.Direction.ASC, "placedAt"));
        SORTS.put("amount", Sort.by(Sort.Direction.DESC, "amount"));
        SORTS.put("customer", Sort.by(Sort.Direction.ASC, "customer"));
    }

    /** The query parameters this route reads; any other is refused. */
    static final Set<String> PARAMETERS = Collections.unmodifiableSet(new java.util.LinkedHashSet<>(List.of("sort", "mealType", "size", "cursor")));

    static final int DEFAULT_SIZE = 5;
    static final int MAX_SIZE = 50;

    /** One order as the list shows it. */
    record OrderView(Long id, String customer, MealType mealType, int amount, Instant placedAt) {
        static OrderView of(OrderEntity o) {
            return new OrderView(o.getId(), o.getCustomer(), o.getMealType(), o.getAmount(), o.getPlacedAt());
        }
    }

    /** One page: the orders, and the cursor of the next page (null on the last). */
    record OrderPage(List<OrderView> items, String next) {
    }

    private final OrderEntityRepository orders;
    private final JsonMapper json;
    private final byte[] key;

    OrderPages(OrderEntityRepository orders, JsonMapper json, @Value("${tiffinbox.cursor-key:}") String cursorKey) {
        this.orders = orders;
        this.json = json;
        if (cursorKey == null || cursorKey.isBlank()) {
            this.key = new byte[32];
            new SecureRandom().nextBytes(this.key);
            LOG.log(System.Logger.Level.INFO, "the order list's cursor key: defaulted (random, this start only; tiffinbox.cursor-key unset)");
        } else {
            this.key = cursorKey.getBytes(StandardCharsets.UTF_8);
            LOG.log(System.Logger.Level.INFO, "the order list's cursor key: set (tiffinbox.cursor-key)");
        }
    }

    @ApiResponse(responseCode = "200", description = "OK", content = @Content(mediaType = "application/json",
            schema = @Schema(implementation = OrderPage.class)))
    @ApiResponse(responseCode = "400", description = "An unknown sort, parameter or meal type, a page size outside 1 to 50, a cursor"
            + " this server did not sign or one written for another sort or filter", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class)))
    @GetMapping("/api/v1/orders")
    OrderPage orderPage(@RequestParam(defaultValue = "newest") String sort, @RequestParam(required = false) String mealType,
                        @RequestParam(required = false) Integer size, @RequestParam(required = false) String cursor,
                        HttpServletRequest request) {
        List<String> unknown = new ArrayList<>();
        for (String name : Collections.list(request.getParameterNames())) if (!PARAMETERS.contains(name)) unknown.add(name);
        if (!unknown.isEmpty()) {
            throw refusal("parameter-unknown", "Unknown parameter", "unknown parameter " + unknown + "; this route reads " + PARAMETERS);
        }
        Sort s = SORTS.get(sort);
        if (s == null) throw refusal("sort-unknown", "Unknown sort", "sort must be one of " + SORTS.keySet());
        int n = size == null ? DEFAULT_SIZE : size;
        if (n < 1 || n > MAX_SIZE) throw refusal("size-invalid", "Page size out of range", "size must be 1 to " + MAX_SIZE);
        ScrollPosition position = ScrollPosition.keyset();
        if (cursor != null) {
            JsonNode c = decode(cursor);
            String cs = c.get("s").asString();
            String cf = c.get("f").isNull() ? null : c.get("f").asString();
            List<String> differ = new ArrayList<>();
            if (!sort.equals(cs)) differ.add("sort (the cursor's " + cs + ", this request's " + sort + ")");
            if (!Objects.equals(mealType, cf)) {
                differ.add("mealType (the cursor's " + (cf == null ? "none" : cf) + ", this request's " + (mealType == null ? "none" : mealType) + ")");
            }
            if (!differ.isEmpty()) {
                throw refusal("cursor-mismatch", "Cursor for another request", "this cursor was written for another request: " + String.join("; ", differ));
            }
            Map<String, Object> keys = new LinkedHashMap<>();
            for (JsonNode k : c.get("k")) {
                String t = k.get(1).asString(), v = k.get(2).asString();
                keys.put(k.get(0).asString(), switch (t) {
                    case "I" -> Instant.parse(v);
                    case "L" -> Long.valueOf(v);
                    case "N" -> Integer.valueOf(v);
                    default -> v;
                });
            }
            position = ScrollPosition.forward(keys);
        }
        MealType filter = null;
        if (mealType != null) {
            filter = Arrays.stream(MealType.values()).filter(m -> m.name().equals(mealType)).findFirst()
                    .orElseThrow(() -> refusal("filter-unknown", "Unknown meal type", "mealType must be one of " + Arrays.toString(MealType.values())));
        }
        Window<OrderEntity> w = filter == null ? orders.findBy(position, s, Limit.of(n)) : orders.findByMealType(filter, position, s, Limit.of(n));
        String next = null;
        if (w.hasNext() && !w.isEmpty()) next = encode(sort, mealType, ((KeysetScrollPosition) w.positionAt(w.size() - 1)).getKeys());
        return new OrderPage(w.getContent().stream().map(OrderView::of).toList(), next);
    }

    private String encode(String sort, String mealType, Map<String, Object> keys) {
        List<List<String>> k = new ArrayList<>();
        for (var e : keys.entrySet()) {
            Object v = e.getValue();
            String t = v instanceof Instant ? "I" : v instanceof Long ? "L" : v instanceof Integer ? "N" : "S";
            k.add(List.of(e.getKey(), t, String.valueOf(v)));
        }
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("s", sort);
        payload.put("f", mealType);
        payload.put("k", k);
        String b = Base64.getUrlEncoder().withoutPadding().encodeToString(json.writeValueAsString(payload).getBytes(StandardCharsets.UTF_8));
        return b + "." + mac(b);
    }

    private JsonNode decode(String cursor) {
        try {
            int dot = cursor.lastIndexOf('.');
            if (dot < 1) throw new IllegalArgumentException("no signature");
            String b = cursor.substring(0, dot);
            if (!MessageDigest.isEqual(mac(b).getBytes(StandardCharsets.US_ASCII), cursor.substring(dot + 1).getBytes(StandardCharsets.US_ASCII))) {
                throw new IllegalArgumentException("bad signature");
            }
            JsonNode c = json.readTree(new String(Base64.getUrlDecoder().decode(b), StandardCharsets.UTF_8));
            if (c.get("s") == null || c.get("f") == null || c.get("k") == null) throw new IllegalArgumentException("not a cursor");
            return c;
        } catch (RuntimeException e) {
            throw refusal("cursor-invalid", "Invalid cursor", "the cursor is not one this server signed");
        }
    }

    private String mac(String s) {
        try {
            Mac m = Mac.getInstance("HmacSHA256");
            m.init(new SecretKeySpec(key, "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(m.doFinal(s.getBytes(StandardCharsets.UTF_8)));
        } catch (java.security.GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }

    private static ErrorResponseException refusal(String type, String title, String detail) {
        ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, detail);
        p.setType(URI.create(TYPE + type));
        p.setTitle(title);
        return new ErrorResponseException(HttpStatus.BAD_REQUEST, p, null);
    }
}
