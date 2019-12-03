package net.lagerwey.rssfeed.rsstojsonconverter

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.core.io.ClassPathResource
import org.springframework.test.context.junit.jupiter.SpringExtension
import java.io.File

@ExtendWith(SpringExtension::class)
@SpringBootTest
internal class RssFeedParserTest {

  @Autowired
  private lateinit var rssFeedConfigurationProperties: RssFeedConfigurationProperties

  @Test
  fun testParseXml() {
    val list = RssFeedParser().parse(ClassPathResource("rss-with-item.xml").url.toExternalForm())
    assertThat(list).extracting("title").containsExactly("RSS Tutorial", "XML Tutorial")
    assertThat(list).extracting("link").containsExactly("https://www.w3schools.com/xml/xml_rss.asp", "https://www.w3schools.com/xml")
  }

  @Test
  fun testParseAtom() {
    val list = RssFeedParser().parse(ClassPathResource("atom-rss.xml").url.toExternalForm())
    assertThat(list).extracting("title").containsExactly("After four years, Rust-based Redox OS is nearly self-hosting", "You can forget about that Black Friday deal: Brit banks crap out just in time for pay day")
    assertThat(list).extracting("link").containsExactly("https://go.theregister.co.uk/feed/www.theregister.co.uk/2019/11/29/after_four_years_rusty_os_nearly_selfhosting/",
      "https://go.theregister.co.uk/feed/www.theregister.co.uk/2019/11/29/black_friday_does_for_uk_banking_sector/")
  }

  @Test
  fun testAllFeeds() {
    val rssFeedParser = RssFeedParser()
    val mapper = jacksonObjectMapper()
    val feedInLocation: FeedInLocation = mapper.readValue(File(rssFeedConfigurationProperties.feedUrl))
    feedInLocation.left.plus(feedInLocation.middle).plus(feedInLocation.right).forEach { feed ->
      rssFeedParser.parse(feed.url)
    }
  }
}