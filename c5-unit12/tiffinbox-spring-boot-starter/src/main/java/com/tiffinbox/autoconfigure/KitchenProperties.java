package com.tiffinbox.autoconfigure;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.bind.DefaultValue;

/**
 * The starter's own keys: tiffinbox.kitchen.name and tiffinbox.kitchen.cooks.
 *
 * @param name  what the kitchen is called
 * @param cooks how many cooks it has
 */
@ConfigurationProperties("tiffinbox.kitchen")
public record KitchenProperties(@DefaultValue("TiffinBox kitchen") String name, @DefaultValue("3") int cooks) {
}
