package net.lagerwey.rssfeed.rsstojsonconverter

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.io.File

@SpringBootTest
@ActiveProfiles("test")
class RssToJsonConverterApplicationTests {

  companion object {
    @BeforeAll
    @JvmStatic
    internal fun beforeAll() {
      println("================== DELETING")
      File("build/generated-json").deleteRecursively()
      assertThat(File("build/generated-json")).doesNotExist()
    }
  }

  @Test
  fun contextLoads() {
    assertThat(File("build/generated-json/feed-tweakers-nieuws.json")).exists()
  }
}
