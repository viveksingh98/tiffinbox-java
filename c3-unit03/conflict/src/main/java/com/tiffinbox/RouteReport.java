package com.tiffinbox;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;

import java.io.File;

/**
 * TiffinBox reads its delivery routes from a YAML file and reports which Jackson
 * actually got loaded. The build is green whichever version wins; only this run says which.
 */
public final class RouteReport {

    public static void main(String[] args) throws Exception {
        ObjectMapper yaml = new ObjectMapper(new YAMLFactory());
        JsonNode routes = yaml.readTree(new File("routes.yaml")).get("routes");

        int stops = 0;
        for (JsonNode r : routes) {
            stops += r.get("stops").asInt();
        }

        System.out.println("routes        : " + routes.size());
        System.out.println("stops         : " + stops);
        System.out.println("jackson-core  : " + com.fasterxml.jackson.core.json.PackageVersion.VERSION);
        System.out.println("databind      : " + com.fasterxml.jackson.databind.cfg.PackageVersion.VERSION);
    }
}
