<?php

$feedConfigs = json_decode(file_get_contents('api/feeds.json'));

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

foreach ($feedConfigs as $feedConfig) {
  echo "URL: " . $feedConfig->url . "\n";

  $xml = file_get_contents($feedConfig->url);
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
    $fp = fopen('api/feed-' . $feedConfig->id . '.json', 'w');
    fwrite($fp, json_encode($feed, 128));
    fclose($fp);
  }

}

?>
