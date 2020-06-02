package net.lagerwey.rssfeed.rsstojsonconverter

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.springframework.boot.ApplicationRunner
import org.springframework.boot.CommandLineRunner
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import java.io.File

@SpringBootApplication
@EnableConfigurationProperties
class RssToJsonConverterApplication {
  @Bean
  fun init(
    jacksonObjectMapper: ObjectMapper,
    rssFeedParser: RssFeedParser,
    rssFeedConfiguration: RssFeedConfigurationProperties
  ) = ApplicationRunner {applicationArguments ->

    do {
      val feedsInputstream = Curl().download(rssFeedConfiguration.feedUrl)
      val feedInLocation: FeedInLocation = jacksonObjectMapper.readValue(feedsInputstream)
      val allFeeds = feedInLocation.left.plus(feedInLocation.middle).plus(feedInLocation.right)
      allFeeds.forEach {
        val feed = rssFeedParser.parse(it)
        writeFeedJson(jacksonObjectMapper, rssFeedConfiguration, feed)
      }
      if (!applicationArguments.containsOption("run-once")) {
        Thread.sleep(5 * 60 * 1000)
      }
    } while(!applicationArguments.containsOption("run-once"))
  }

  private fun writeFeedJson(
    jacksonObjectMapper: ObjectMapper,
    rssFeedConfiguration: RssFeedConfigurationProperties,
    feed: Feed
  ) {
    val file = File(rssFeedConfiguration.outputJson, "feed-${feed.id}.json")
    file.parentFile.mkdirs()
    jacksonObjectMapper.writeValue(file, feed.items)
  }
}

fun main(args: Array<String>) {
  runApplication<RssToJsonConverterApplication>(*args)
}
