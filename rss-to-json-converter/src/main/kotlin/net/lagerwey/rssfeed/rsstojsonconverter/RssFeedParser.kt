package net.lagerwey.rssfeed.rsstojsonconverter

import org.springframework.stereotype.Component
import org.w3c.dom.Document
import org.w3c.dom.NodeList
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.xpath.XPathConstants
import javax.xml.xpath.XPathFactory

@Component
class RssFeedParser {
  fun parse(rssXmlUrl: String): List<FeedItem> {
    println(rssXmlUrl)

    val text = Curl().download(rssXmlUrl)
    val factory = DocumentBuilderFactory.newInstance()
    val builder = factory.newDocumentBuilder()
    val doc: Document = builder.parse(text)

    doc.documentElement.normalize()

    val feed = mutableListOf<FeedItem>()

    val xPath = XPathFactory.newInstance().newXPath()
    val items = xPath.compile("//*[local-name()='item']").evaluate(doc.documentElement, XPathConstants.NODESET) as NodeList
    if (items.length == 0) {
      doc.documentElement.childNodes.toList().forEach { entry ->
        if (entry.nodeName == "entry") {
          val link = entry.childNodes.toList().firstOrNull { it.nodeName == "link" }?.attributes?.getNamedItem("href")
          val title = entry.childNodes.toList().firstOrNull { it.nodeName == "title" }
          feed.add(FeedItem(title, link))
        }
      }
    } else {
      items.toList().forEach { entry ->
        val link = entry.childNodes.toList().firstOrNull { it.nodeName == "link" }
        val title = entry.childNodes.toList().firstOrNull { it.nodeName == "title" }
        feed.add(FeedItem(title, link))
      }
    }

    return feed
  }
}