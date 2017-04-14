module FeedConfigs.View exposing (..)

import FeedConfigs.Types exposing (FeedConfig)
import FeedItem exposing (viewFeed)
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)
import Styling.Css as Css


viewFeeds : List FeedConfig -> Html msg
viewFeeds feedConfigList =
    div [ class [ Css.Feeder ] [] ]
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
