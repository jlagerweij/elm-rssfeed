module FeedConfigs.View exposing (..)

import FeedConfigs.Types exposing (FeedConfig)
import FeedItem exposing (viewFeed)
import Html exposing (Html, div)
import Html.Attributes exposing (id)
import Tachyons exposing (classes)
import Tachyons.Classes exposing (dt, dt__fixed, dtc, pl3, pv4, sans_serif, tc)


viewFeeds : List FeedConfig -> Html msg
viewFeeds feedConfigList =
    div [ classes [ dt, dt__fixed, sans_serif ] ]
        [ viewFeedItemsInColumn "left" feedConfigList
        , viewFeedItemsInColumn "middle" feedConfigList
        , viewFeedItemsInColumn "right" feedConfigList
        ]


viewFeedItemsInColumn : String -> List FeedConfig -> Html msg
viewFeedItemsInColumn columnName feedConfigList =
    div [ classes [ dtc, pv4, pl3 ], id columnName ]
        (feedConfigList
            |> List.filter (\feedConfig -> feedConfig.location == columnName)
            |> List.map (\feedConfig -> viewFeed feedConfig.id feedConfig.items)
        )
