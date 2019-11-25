package net.lagerwey.rssfeed.rsstojsonconverter

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class RssToJsonConverterApplication

fun main(args: Array<String>) {
	runApplication<RssToJsonConverterApplication>(*args)
}
