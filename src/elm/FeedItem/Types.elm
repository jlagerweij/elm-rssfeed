module FeedItem.Types exposing (..)

import RemoteData exposing (WebData)


type alias FeedItemListWebData =
    WebData (List FeedItem)


type alias FeedItem =
    { title : String
    , link : String
    }
