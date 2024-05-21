<?php

$feedConfigs = json_decode(file_get_contents('http://web/api/config.json'));

class Item
{
  public $title;
  public $link;

  public function __construct($title, $link)
  {
    $this->link = $link;
    $this->title = $title;
  }
}

function addItem($title, $link, $feed)
{
  if ($title == "") {
    echo "WARNING: Empty title!";
  }
  if ($link == "") {
    echo "WARNING: Empty link!";
  }

  $item = new Item($title, $link);
  $feed[] = $item;
  return array($item, $feed);
}

function getLinkAndTitleFromEntry($feed, $xml)
{
  $children = $xml->children();
  foreach($children as $child) {
    if ($child->getName() === 'link') {
      $link = (string)$child->attributes;
    }
    if ($child->getName() === 'title') {
      $title = (string)$child->title;
    }
  }

  echo "item Link: $link\n";
  if (count($feed) < 10) {
    list($item, $feed) = addItem($title, $link, $feed);
  }
}

function getContents($url) {
  echo "URL: " . str_pad($url, 80) . "\t";

  $context = stream_context_create(
    array(
      'http' => array(
        'user_agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0',
      ),
    ));

  return file_get_contents($url, false, $context);
}

foreach (array_merge($feedConfigs->left, $feedConfigs->middle, $feedConfigs->right) as $feedConfig) {
  $xml = getContents($feedConfig->url);
  if (strpos($xml, 'ISO-8859-15') !== false || strpos($xml, 'iso-8859-15') !== false) {
    $xml = iconv("ISO-8859-15", "UTF-8", $xml);
    $xml = str_replace("ISO-8859-15", "UTF-8", $xml);
    $xml = str_replace("iso-8859-15", "UTF-8", $xml);
  }

  $rss = simplexml_load_string($xml);
  if ($rss === FALSE) {
    echo "Error!\n";
  } else {
    $feed = array();

    $items = $rss->xpath('//item');
    if (count($items) == 0) {
      $entries = $rss->children();
      foreach ($entries as $entry) {
        $entries = $rss->children();
        if ($entry->getName() === 'item') {
          $link = (string)$entry->link;
          $title = (string)$entry->title;

          if (count($feed) < 10) {
            list($item, $feed) = addItem($title, $link, $feed);
          }
        }
        if ($entry->getName() === 'entry') {
          $link = (string)$entry->link['href'];
          $title = (string)$entry->title;

          if (count($feed) < 10) {
            list($item, $feed) = addItem($title, $link, $feed);
          }
        }
      }
    } else {
      foreach ($items as $item) {
        $link = (string)$item->link;
        $title = (string)$item->title;

        if (count($feed) < 10) {
          list($item, $feed) = addItem($title, $link, $feed);
        }
      }
    }

    echo 'writing ' . count($feed) . ' to : feed-' . $feedConfig->id . '.json' . "\n";
    $fp = fopen('api/feeds/' . $feedConfig->id, 'w');
    fwrite($fp, json_encode($feed, 128));
    fclose($fp);
  }

}

?>
