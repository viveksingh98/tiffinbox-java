package com.tiffinbox.web;

import org.springframework.data.elasticsearch.annotations.Highlight;
import org.springframework.data.elasticsearch.annotations.HighlightField;
import org.springframework.data.elasticsearch.core.SearchHits;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import java.util.List;

/**
 * Course 8, unit 21: the index dishes, through Spring Data Elasticsearch - a repository Boot's Elasticsearch repositories scan finds
 * under the profile "dev" (application.yaml excludes that scan, application-dev.yaml clears the list). Its proxy creates the index at
 * start when it is missing, with Dish's settings and mapping. findByName is derived from its name: the client sends a query_string
 * query on the field name (the request's own line, by the client's trace logger, ../c8-unit21, anchor), so Elasticsearch analyses
 * the words with the field's analyzer, "dish", before it looks them up.
 *
 * <p>Course 8, unit 22: searchByName sends the same query_string with a highlight request for the field name, and returns
 * SearchHits: each document Elasticsearch found, with the fragment of its name the index marked (../c8-unit22, highlight). The repository's save is also the write the
 * listener DishIndexSync makes for each dish row a POST /dishes commits: it sends the document with refresh=false, then a _refresh
 * of the index, and the count that follows it reads the new document (../c8-unit22, nrt and sync). The index stays a copy of the
 * rows: the start rebuilds it, and the listener adds each committed row after the commit.
 */
public interface Dishes extends ElasticsearchRepository<Dish, String> {

    /** The dishes whose name holds the words given, as the field's analyzer reads them. */
    List<Dish> findByName(String name);

    /** The same query; each document Elasticsearch found comes with the fragment of its name marked in em tags (the field's highlight). */
    @Highlight(fields = @HighlightField(name = "name"))
    SearchHits<Dish> searchByName(String name);
}
