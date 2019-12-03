package net.lagerwey.rssfeed.rsstojsonconverter

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.springframework.boot.CommandLineRunner
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean

@SpringBootApplication
@EnableConfigurationProperties
class RssToJsonConverterApplication {
  @Bean
  fun init(
    jacksonObjectMapper: ObjectMapper,
    rssFeedParser: RssFeedParser,
    rssFeedConfiguration: RssFeedConfigurationProperties
  ) = CommandLineRunner {
    val feedsInputstream = Curl().download(rssFeedConfiguration.feedUrl)
    val feedInLocation: FeedInLocation = jacksonObjectMapper.readValue(feedsInputstream)
    feedInLocation.left.plus(feedInLocation.middle).plus(feedInLocation.right).forEach { feed ->
      rssFeedParser.parse(feed.url)
    }
  }
}

fun main(args: Array<String>) {
  runApplication<RssToJsonConverterApplication>(*args)
}
