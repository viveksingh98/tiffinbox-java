package com.tiffinbox.web;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import java.util.List;

/**
 * Course 8, unit 21: the index dishes, through Spring Data Elasticsearch - a repository Boot's Elasticsearch repositories scan finds
 * under the profile "dev" (application.yaml excludes that scan, application-dev.yaml clears the list). Its proxy creates the index at
 * start when it is missing, with Dish's settings and mapping. findByName is derived from its name: the client sends a query_string
 * query on the field name (the request's own line, by the client's trace logger, ../c8-unit21, anchor), so Elasticsearch analyses
 * the words with the field's analyzer, "dish", before it looks them up.
 */
public interface Dishes extends ElasticsearchRepository<Dish, String> {

    /** The dishes whose name holds the words given, as the field's analyzer reads them. */
    List<Dish> findByName(String name);
}
