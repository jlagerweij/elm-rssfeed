module FeedConfigs exposing (..)

import FeedBox exposing (feedBoxView)
import FeedItem exposing (FeedItem, FeedItemListWebData, viewFeed)
import Html exposing (..)
import Html.Attributes exposing (href, id, target)
import RemoteData exposing (RemoteData(Success), WebData)
import Styling.Css as Css
import Styling.HtmlCss exposing (bClass, class, nClass)


type alias FeedConfigListWebData =
    WebData (List FeedConfig)


type alias FeedConfig =
    { id : String
    , url : String
    , location : String
    , items : Maybe FeedItemListWebData
    }


viewFeeds : List FeedConfig -> Html msg
viewFeeds feedConfigList =
    div [ class [ Css.Feeder ] [ "pure-g" ] ]
        [ viewFeedItemsInColumn "left" feedConfigList
        , viewFeedItemsInColumn "middle" feedConfigList
        , viewFeedItemsInColumn "right" feedConfigList
        ]


viewFeedItemsInColumn : String -> List FeedConfig -> Html msg
viewFeedItemsInColumn columnName feedConfigList =
    div [ class [ Css.Column ] [ "pure-u-1-3" ], id columnName ]
        (feedConfigList
            |> List.filter (\feedConfig -> feedConfig.location == columnName)
            |> List.map (\feedConfig -> viewFeed feedConfig.id feedConfig.items)
        )
