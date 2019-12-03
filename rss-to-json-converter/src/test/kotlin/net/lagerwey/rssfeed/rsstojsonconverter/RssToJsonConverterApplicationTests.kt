package net.lagerwey.rssfeed.rsstojsonconverter

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest
import java.io.File

@SpringBootTest
class RssToJsonConverterApplicationTests {

	@Test
	fun contextLoads() {
    File("../../../../src/static/api/feeds.json")
	}
}
