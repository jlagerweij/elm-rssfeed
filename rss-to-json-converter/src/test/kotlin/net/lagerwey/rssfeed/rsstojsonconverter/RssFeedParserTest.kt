package net.lagerwey.rssfeed.rsstojsonconverter

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.springframework.core.io.ClassPathResource
import org.springframework.test.context.junit.jupiter.SpringExtension

@ExtendWith(SpringExtension::class)
internal class RssFeedParserTest {

  @Test
  fun testParseXml() {
    val feed = Feed(id = "1", url = ClassPathResource("rss-with-item.xml").url.toExternalForm())
    val list = RssFeedParser().parse(feed).items
    assertThat(list).extracting("title").containsExactly("RSS Tutorial", "XML Tutorial")
    assertThat(list).extracting("link").containsExactly("https://www.w3schools.com/xml/xml_rss.asp", "https://www.w3schools.com/xml")
  }

  @Test
  fun testParseAtom() {
    val feed = Feed(id = "1", url = ClassPathResource("atom-rss.xml").url.toExternalForm())
    val list = RssFeedParser().parse(feed).items
    assertThat(list).extracting("title").containsExactly("After four years, Rust-based Redox OS is nearly self-hosting", "You can forget about that Black Friday deal: Brit banks crap out just in time for pay day")
    assertThat(list).extracting("link").containsExactly("https://go.theregister.co.uk/feed/www.theregister.co.uk/2019/11/29/after_four_years_rusty_os_nearly_selfhosting/",
      "https://go.theregister.co.uk/feed/www.theregister.co.uk/2019/11/29/black_friday_does_for_uk_banking_sector/")
  }
}