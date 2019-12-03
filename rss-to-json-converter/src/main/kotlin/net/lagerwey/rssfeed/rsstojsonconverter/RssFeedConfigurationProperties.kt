package net.lagerwey.rssfeed.rsstojsonconverter

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@ConfigurationProperties("rssfeed")
class RssFeedConfigurationProperties {
  lateinit var feedUrl: String
}