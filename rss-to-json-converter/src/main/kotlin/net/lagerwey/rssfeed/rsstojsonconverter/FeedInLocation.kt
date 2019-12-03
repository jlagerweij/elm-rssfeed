package net.lagerwey.rssfeed.rsstojsonconverter

data class FeedInLocation(
  val left: List<Feed>,
  val middle: List<Feed>,
  val right: List<Feed>
)

data class Feed(
  val id: String,
  val title: String?,
  val url: String
)
