module FeedItem.Types exposing (FeedItem, FeedItemListWebData)

import RemoteData exposing (WebData)


type alias FeedItemListWebData =
    WebData (List FeedItem)


type alias FeedItem =
    { title : String
    , link : String
    }
