package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;

import com.github.dockerjava.api.model.ExposedPort;
import com.github.dockerjava.api.model.PortBinding;
import com.github.dockerjava.api.model.Ports;
import org.bson.Document;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.mongodb.test.autoconfigure.DataMongoTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Import;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.mongodb.MongoDBContainer;
import org.testcontainers.utility.DockerImageName;
import slice.MongoSlice;

import java.util.List;
import java.util.TreeSet;

/**
 * Course 8, unit 18: the menu TiffinBox ships, on MongoDB in a container. {@code @DataMongoTest} starts Spring Data MongoDB's slice
 * (slice/MongoSlice): a MongoClient and the MongoTemplate, no web layer - so the test imports Menus itself, a
 * {@code @RestController} the slice would leave out, under the profile it carries, "dev". application.yaml, which the slice reads,
 * excludes Boot's MongoDB auto-configurations; application-dev.yaml, read under "dev", clears that list, so the slice has its
 * MongoTemplate. The container is the image the course pinned, by its digest, with the variable this machine's kernel needs
 * (compose.yaml says why), a standalone server - MongoDBContainer's own shape; Boot's service connection hands the slice its
 * address. Its port is published on 127.0.0.1:20578 alone: Testcontainers 2.0.5 publishes a container's port on every interface
 * of the host (0.0.0.0 and ::, read three times off Docker's record of this container's bindings, ../c8-unit18) unless the test
 * names the address; the service connection reads the mapped port, 20578. Boot's Docker Compose support does not start in a test. Run by mvn verify only (the container-tests execution,
 * tiffinbox-web/pom.xml).
 *
 * <p>Two witnesses in one test: the shipped bean inserts one day and reads it back by its id, and the driver's own collection reads
 * the same stored document raw - its _id's type and _class, the type hint the mapper wrote.
 *
 * <p>Course 8, unit 19: a second test, the same two witnesses for the copied orders - OrderDocuments, the repository the slice now
 * scans for (slice/MongoSlice), saves three orders and its derived finder findByMealType reads the VEG ones back; the driver's
 * collection reads one of them raw. 18 + 10 under mvn verify. (Course 8, unit 20: 18 + 11 - the third test below. Course 8, unit 21:
 * 18 + 12 - ElasticsearchIT beside it. Course 8, unit 22: 18 + 13 - ElasticsearchIT's second test.)
 *
 * <p>Course 8, unit 20: a third test, the index - under "dev", whose application-dev.yaml sets
 * spring.data.mongodb.auto-index-creation, OrderDocuments saves three orders and the mapper's own IndexOperations names the index on
 * customer (the mapper's witness); the driver runs explain on a find of one customer and the server's plan walks that index,
 * IXSCAN (the store's witness). The container stays the standalone above: this test is the index, not a transaction.
 *
 * <p>Course 8, unit 26: a fourth test, the repository's fragment on the slice - OrderDocuments saves three orders (Ravi-1 and Ravi-2
 * at 240, Sunil-1 at 300) and totalsByCustomer(), OrderTotals' method that OrderTotalsImpl answers, groups them on MongoDB's server:
 * Ravi 480, then Sunil 300, as CustomerTotal. The slice's scan (slice/MongoSlice) finds OrderTotalsImpl beside OrderDocuments, by its
 * name, as the "dev" start does. 18 + 14 under mvn verify.
 *
 * <p>Course 8, unit 27: the class prints its container's bindings once, before its first test, off Docker's own record of the
 * container: IT BINDINGS, then each exposed port with its host address and port - the line every IT of TiffinBox prints.
 *
 * <p>Course 9, unit 04: the container's port is published on 127.0.0.1:21283 alone - one fixed port per IT, 21280-21284, Course 9's IT
 * block; Course 8's 20578 and 20615 and Docker's own port for the three others are gone (../c9-unit04, tests).
 */@DataMongoTest
@ContextConfiguration(classes = MongoSlice.class)
@Import(Menus.class)
@ActiveProfiles("dev")
@Testcontainers
class MongoDatastoreIT {

    @Container
    @ServiceConnection
    static MongoDBContainer mongo = new MongoDBContainer(
            DockerImageName.parse("mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd").asCompatibleSubstituteFor("mongo"))
            .withEnv("GLIBC_TUNABLES", "glibc.pthread.rseq=1")
            .withExposedPorts(27017)
            .withCreateContainerCmdModifier(cmd -> cmd.getHostConfig().withPortBindings(
                    new PortBinding(Ports.Binding.bindIpAndPort("127.0.0.1", 21283), new ExposedPort(27017))));

    /** Course 8, unit 27: this IT's own container, each exposed port with its host address and port, off Docker's own record. */
    @BeforeAll
    static void printBindings() {
        var out = new TreeSet<String>();
        mongo.getContainerInfo().getNetworkSettings().getPorts().getBindings().forEach((p, bs) -> { if (bs != null) for (var b : bs) out.add(p + " -> " + b.getHostIp() + ":" + b.getHostPortSpec()); });
        System.out.println("IT BINDINGS MongoDatastoreIT " + out);
    }

    @Autowired Menus menus;
    @Autowired MongoTemplate template;
    @Autowired OrderDocuments orderDocuments;

    @Test
    void aDayOfTheMenuIsOneDocumentWithItsItemsInside() {
        var ports = new TreeSet<String>();
        mongo.getContainerInfo().getNetworkSettings().getPorts().getBindings().forEach((p, bs) -> {
            for (var b : bs) ports.add(b.getHostIp() + ":" + b.getHostPortSpec() + "->" + p);
        });
        System.out.println("MONGO IT the container's port bindings (Docker's own record): " + ports);
        menus.reset();
        MenuDay day = MenuDay.forDays(19).get(18);
        menus.fill(List.of(day));
        MenuDay back = menus.menu("day-19").getBody();
        var names = new TreeSet<String>();
        back.items().forEach(i -> names.add(i.name()));
        System.out.println("MONGO IT day-19, through Menus: items " + back.items().size() + " · " + names);
        Document raw = template.getDb().getCollection("menu").find(new Document("_id", "day-19")).first();
        System.out.println("MONGO IT the same document, through the driver's collection: _id " + raw.get("_id").getClass().getSimpleName()
                + " · _class " + raw.get("_class") + " · items " + raw.getList("items", Document.class).size()
                + " · documents in menu " + template.getDb().getCollection("menu").countDocuments());
        assertThat(back.items()).hasSize(3);
        assertThat(back).isEqualTo(day);
        assertThat(raw.get("_id")).isInstanceOf(String.class);
        assertThat(raw.get("_class")).isEqualTo("com.tiffinbox.web.MenuDay");
        assertThat(raw.getList("items", Document.class)).hasSize(3);
        assertThat(template.getDb().getCollection("menu").countDocuments()).isEqualTo(1);
        menus.reset();
    }

    @Test
    void theDerivedFinderReadsTheCopiedOrdersOfOneMealType() {
        orderDocuments.deleteAll();
        orderDocuments.saveAll(List.of(new OrderDocument("Ravi-1", "Ravi", "VEG", 1, 240), new OrderDocument("Sunil-1", "Sunil", "VEG", 1, 300),
                new OrderDocument("Meera-1", "Meera", "NON_VEG", 1, 150)));
        var veg = new TreeSet<String>();
        orderDocuments.findByMealType("VEG").forEach(o -> veg.add(o.id()));
        System.out.println("MONGO IT orders, through OrderDocuments: count " + orderDocuments.count() + " · findByMealType(\"VEG\") " + veg);
        Document raw = template.getDb().getCollection("orders").find(new Document("_id", "Ravi-1")).first();
        System.out.println("MONGO IT Ravi-1, through the driver's collection: _id " + raw.get("_id").getClass().getSimpleName() + " · _class " + raw.get("_class")
                + " · mealType " + raw.get("mealType") + " · value " + raw.get("value"));
        assertThat(veg).containsExactly("Ravi-1", "Sunil-1");
        assertThat(raw.get("_id")).isInstanceOf(String.class);
        assertThat(raw.get("_class")).isEqualTo("com.tiffinbox.web.OrderDocument");
        assertThat(raw.get("mealType")).isEqualTo("VEG");
        orderDocuments.deleteAll();
    }

    @Test
    void theKeyMakesTheIndexOnCustomerAndTheFindWalksIt() {
        orderDocuments.deleteAll();
        orderDocuments.saveAll(List.of(new OrderDocument("Ravi-1", "Ravi", "VEG", 1, 240), new OrderDocument("Ravi-2", "Ravi", "VEG", 2, 240),
                new OrderDocument("Sunil-1", "Sunil", "VEG", 1, 300)));
        var names = new TreeSet<String>();
        template.indexOps(OrderDocument.class).getIndexInfo().forEach(i -> names.add(i.getName()));
        System.out.println("MONGO IT orders, the mapper's IndexOperations.getIndexInfo(): " + names);
        Document plan = template.getDb().runCommand(new Document("explain", new Document("find", "orders").append("filter", new Document("customer", "Ravi")))
                .append("verbosity", "executionStats"));
        var stages = new java.util.ArrayList<String>();
        for (Document st = plan.get("queryPlanner", Document.class).get("winningPlan", Document.class); st != null; st = st.get("inputStage", Document.class)) {
            stages.add(st.getString("stage"));
        }
        Document stats = plan.get("executionStats", Document.class);
        System.out.println("MONGO IT explain of find {customer: Ravi}, through the driver's runCommand: winningPlan " + String.join(" > ", stages)
                + " · nReturned " + stats.get("nReturned") + " · totalKeysExamined " + stats.get("totalKeysExamined") + " · totalDocsExamined " + stats.get("totalDocsExamined"));
        assertThat(names).containsExactly("_id_", "customer");
        assertThat(stages).contains("IXSCAN");
        assertThat(stats.get("nReturned")).isEqualTo(2);
        assertThat(stats.get("totalDocsExamined")).isEqualTo(2);
        orderDocuments.deleteAll();
    }

    @Test
    void theFragmentTotalsTheOrdersPerCustomer() {
        orderDocuments.deleteAll();
        orderDocuments.saveAll(List.of(new OrderDocument("Ravi-1", "Ravi", "VEG", 1, 240), new OrderDocument("Ravi-2", "Ravi", "VEG", 2, 240),
                new OrderDocument("Sunil-1", "Sunil", "VEG", 1, 300)));
        List<CustomerTotal> totals = orderDocuments.totalsByCustomer();
        System.out.println("MONGO IT the fragment's totalsByCustomer(), through OrderDocuments: " + totals);
        assertThat(totals).containsExactly(new CustomerTotal("Ravi", 480), new CustomerTotal("Sunil", 300));
        orderDocuments.deleteAll();
    }
}
