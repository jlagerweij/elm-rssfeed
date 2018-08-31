module FeedConfigs.Types exposing (FeedConfig, FeedConfigListWebData, Model, Msg(..))

import FeedItem.Types exposing (FeedItemListWebData)
import RemoteData exposing (WebData)


type alias Model =
    { feedConfigWebData : FeedConfigListWebData
    }


type Msg
    = FeedConfigsResponse FeedConfigListWebData


type alias FeedConfigListWebData =
    WebData (List FeedConfig)


type alias FeedConfig =
    { id : String
    , url : String
    , location : String
    , items : Maybe FeedItemListWebData
    }
