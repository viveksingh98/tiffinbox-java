package com.tiffinbox;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import java.util.List;
import java.util.Map;

/** Reads the delivery routes TiffinBox drives every morning out of a YAML file. */
public final class Routes {
    public static void main(String[] args) throws Exception {
        ObjectMapper yaml = new ObjectMapper(new YAMLFactory());
        String doc = """
                - area: North Block
                  stops: 14
                - area: River Lane
                  stops: 9
                """;
        List<Map<String, Object>> routes = yaml.readValue(doc, List.class);
        System.out.println("routes : " + routes.size());
        for (Map<String, Object> r : routes) {
            System.out.println("  " + r.get("area") + " -> " + r.get("stops") + " stops");
        }
    }
}
