package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.nodes.info.NodesInfoMetric;
import com.github.dockerjava.api.model.ExposedPort;
import com.github.dockerjava.api.model.PortBinding;
import com.github.dockerjava.api.model.Ports;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.elasticsearch.test.autoconfigure.DataElasticsearchTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.testcontainers.elasticsearch.ElasticsearchContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;
import slice.ElasticsearchSlice;

import java.util.Arrays;
import java.util.List;
import java.util.TreeSet;

/**
 * Course 8, unit 21: the index of the dishes TiffinBox ships, on Elasticsearch in a container. {@code @DataElasticsearchTest} starts
 * Spring Data Elasticsearch's slice (slice/ElasticsearchSlice): the client, the template and Dishes, no web layer, under the profile
 * it carries, "dev" - application.yaml, which the slice reads, excludes Boot's Elasticsearch auto-configurations, and
 * application-dev.yaml, read under "dev", clears that list. Boot's Docker Compose support does not start in a test. The container is
 * the image the course pinned, by its digest, with five of the six settings compose.yaml names as environment variables and the sixth,
 * the heap, as ES_JAVA_OPTS too (Testcontainers' own ElasticsearchContainer sets discovery.type=single-node itself, and a heap file of
 * its own that ES_JAVA_OPTS overrides); Boot's service connection hands the slice its address. Its port 9200 is the only one exposed,
 * published on 127.0.0.1:20615 alone (Course 8, unit 22: 20615 since - 20606 was unit 21's slot): Testcontainers 2.0.5
 * publishes on every interface unless the test names the address, as
 * MongoDatastoreIT's does. Run by mvn verify only (the container-tests execution, tiffinbox-web/pom.xml).
 *
 * <p>Two witnesses in one test: Dishes, the shipped repository, saves three dishes into an index it created with Dish's settings
 * and finds the vegetarian one, alone, for veg; and the client's own _analyze, on that index with its analyzer "dish", lists the
 * tokens it stores for Vegetarian Lunch Box, veg among them. 18 + 12 under mvn verify (Course 8, unit 22: 18 + 13 since).
 *
 * <p>Course 8, unit 22: another test - Dishes.searchByName, the shipped repository's highlighted search, on the same three dishes:
 * one document Elasticsearch finds for veg, the vegetarian box, and the fragment it marked in its name. The slice holds no JPA and no transaction
 * manager, so the listener that copies a committed row (DishIndexSync) is not this test's: ../c8-unit22's anchor and sync measure it.
 *
 * <p>Course 8, unit 27: the class prints its container's bindings once, before its first test, off Docker's own record of the
 * container: IT BINDINGS, then each exposed port with its host address and port - the line every IT of TiffinBox prints.
 *
 * <p>Course 9, unit 04: the container's port is published on 127.0.0.1:21284 alone - one fixed port per IT, 21280-21284, Course 9's IT
 * block; Course 8's 20578 and 20615 and Docker's own port for the three others are gone (../c9-unit04, tests).
 */@DataElasticsearchTest
@ContextConfiguration(classes = ElasticsearchSlice.class)
@ActiveProfiles("dev")
@Testcontainers
class ElasticsearchIT {

    @Container
    @ServiceConnection
    static ElasticsearchContainer elasticsearch = new ElasticsearchContainer(
            DockerImageName.parse("docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403")
                    .asCompatibleSubstituteFor("docker.elastic.co/elasticsearch/elasticsearch"))
            .withEnv("xpack.security.enabled", "false")
            .withEnv("xpack.ml.enabled", "false")
            .withEnv("ingest.geoip.downloader.enabled", "false")
            .withEnv("xpack.inference.elastic.authorization.enabled", "false")
            .withEnv("ES_JAVA_OPTS", "-Xms512m -Xmx512m")
            .withExposedPorts(9200)
            .withCreateContainerCmdModifier(cmd -> cmd.getHostConfig().withPortBindings(
                    new PortBinding(Ports.Binding.bindIpAndPort("127.0.0.1", 21284), new ExposedPort(9200))));

    /** Course 8, unit 27: this IT's own container, each exposed port with its host address and port, off Docker's own record. */
    @BeforeAll
    static void printBindings() {
        var out = new TreeSet<String>();
        elasticsearch.getContainerInfo().getNetworkSettings().getPorts().getBindings().forEach((p, bs) -> { if (bs != null) for (var b : bs) out.add(p + " -> " + b.getHostIp() + ":" + b.getHostPortSpec()); });
        System.out.println("IT BINDINGS ElasticsearchIT " + out);
    }

    @Autowired Dishes dishes;
    @Autowired ElasticsearchClient client;

    @Test
    void vegFindsTheVegetarianDishAloneWithTheDishAnalyzer() throws Exception {
        var ports = new TreeSet<String>();
        elasticsearch.getContainerInfo().getNetworkSettings().getPorts().getBindings().forEach((p, bs) -> {
            if (bs != null) for (var b : bs) ports.add(b.getHostIp() + ":" + b.getHostPortSpec() + "->" + p);
        });
        System.out.println("ES IT the container's port bindings (Docker's own record): " + ports);
        var env = new TreeSet<>(Arrays.asList(elasticsearch.getContainerInfo().getConfig().getEnv()));
        env.removeIf(e -> e.startsWith("PATH=") || e.startsWith("HOSTNAME="));
        System.out.println("ES IT the container's environment, as run (PATH and HOSTNAME left out): " + env);
        System.out.println("ES IT the server's version (the client's info()): " + client.info().version().number());
        long heap = client.nodes().info(i -> i.metric(NodesInfoMetric.Jvm)).nodes().values().iterator().next().jvm().mem().heapMaxInBytes();
        System.out.println("ES IT heap_max_in_bytes (the client's nodes info, jvm): " + heap);
        dishes.deleteAll();
        dishes.saveAll(List.of(new Dish("1", "Vegetarian Lunch Box", "VEG", 110), new Dish("2", "Vegetable Curry with Rice", "VEG", 110),
                new Dish("8", "Vegan Lunch Box", "VEGAN", 130)));
        List<String> veg = dishes.findByName("veg").stream().map(Dish::name).toList();
        System.out.println("ES IT Dishes.findByName(\"veg\") of three saved: " + veg);
        List<String> tokens = client.indices().analyze(a -> a.index("dishes").analyzer("dish").text("Vegetarian Lunch Box"))
                .tokens().stream().map(t -> t.token()).toList();
        System.out.println("ES IT _analyze on dishes, analyzer dish, \"Vegetarian Lunch Box\" (the client's): " + tokens);
        assertThat(ports).containsExactly("127.0.0.1:21284->9200/tcp");
        assertThat(heap).isEqualTo(536870912L);
        assertThat(veg).containsExactly("Vegetarian Lunch Box");
        assertThat(tokens).contains("veg");
    }

    @Test
    void searchByNameMarksTheWordTheAnalyzerMatched() {
        dishes.deleteAll();
        dishes.saveAll(List.of(new Dish("1", "Vegetarian Lunch Box", "VEG", 110), new Dish("2", "Vegetable Curry with Rice", "VEG", 110),
                new Dish("8", "Vegan Lunch Box", "VEGAN", 130)));
        var hits = dishes.searchByName("veg").getSearchHits();
        List<String> ids = hits.stream().map(h -> h.getContent().id()).toList();
        List<String> fragment = hits.isEmpty() ? List.of() : hits.get(0).getHighlightField("name");
        System.out.println("ES IT Dishes.searchByName(\"veg\") of three saved: ids " + ids + " · the fragment of the first " + fragment);
        assertThat(ids).containsExactly("1");
        assertThat(fragment).containsExactly("<em>Vegetarian</em> Lunch Box");
    }
}
