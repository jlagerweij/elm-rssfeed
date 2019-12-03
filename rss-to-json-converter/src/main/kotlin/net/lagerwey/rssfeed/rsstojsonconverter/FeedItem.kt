package net.lagerwey.rssfeed.rsstojsonconverter

import org.w3c.dom.Node

class FeedItem(title: Node?, link: Node?) {
  private val title: String
  private val link: String

  init {
    if (title == null) {
      println("WARNING: empty title!")
    }
    if (link == null) {
      println("WARNING: empty link!")
    }
    this.title = title?.textContent ?: ""
    this.link = link?.textContent ?: ""
  }
}
