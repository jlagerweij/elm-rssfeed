package net.lagerwey.rssfeed.rsstojsonconverter

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.springframework.boot.CommandLineRunner
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import java.io.File

@SpringBootApplication
class RssToJsonConverterApplication {
  @Bean
  fun init(
    jacksonObjectMapper: ObjectMapper,
    rssFeedParser: RssFeedParser
  ) = CommandLineRunner {
    val feedsInputstream = Curl().download("http://192.168.0.4:89/api/feeds.json")
    val feedInLocation: FeedInLocation = jacksonObjectMapper.readValue(feedsInputstream)
    feedInLocation.left.plus(feedInLocation.middle).plus(feedInLocation.right).forEach { feed ->
      rssFeedParser.parse(feed.url)
    }
  }
}

fun main(args: Array<String>) {
  runApplication<RssToJsonConverterApplication>(*args)
}
