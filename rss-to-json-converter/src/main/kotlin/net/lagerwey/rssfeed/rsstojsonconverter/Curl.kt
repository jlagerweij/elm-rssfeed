package net.lagerwey.rssfeed.rsstojsonconverter

import org.springframework.core.io.DefaultResourceLoader
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL


class Curl {
  fun download(url: String): InputStream {
    val resource = DefaultResourceLoader().getResource(url)

    var connection = resource.url.openConnection()
    if (connection is HttpURLConnection) {
      connection.readTimeout = 5000
      connection.addRequestProperty("Accept-Language", "en-US,en;q=0.8")
      connection.addRequestProperty("User-Agent", "Mozilla")
      connection.addRequestProperty("Referer", "google.com")

      connection = followRedirect(connection, 0)
    }

    return connection.getInputStream()
  }

  private fun followRedirect(connection: HttpURLConnection, depth: Int): HttpURLConnection {
    if (depth == 5) {
      throw IllegalStateException("Too many redirects. Depth of $depth after following redirects...")
    }
    val status: Int = connection.responseCode
    val redirect =
      status == HttpURLConnection.HTTP_MOVED_TEMP || status == HttpURLConnection.HTTP_MOVED_PERM || status == HttpURLConnection.HTTP_SEE_OTHER

    return if (redirect) {
      val newUrl: String = connection.getHeaderField("Location")
      val cookies: String = connection.getHeaderField("Set-Cookie") ?: ""

      val redirectConnection = URL(newUrl).openConnection() as HttpURLConnection
      redirectConnection.setRequestProperty("Cookie", cookies)
      redirectConnection.addRequestProperty("Accept-Language", "en-US,en;q=0.8")
      redirectConnection.addRequestProperty("User-Agent", "Mozilla")
      redirectConnection.addRequestProperty("Referer", "google.com")
      println("Redirect ${depth} to URL : $newUrl")
      followRedirect(redirectConnection, depth + 1)
    } else {
      connection
    }
  }

}