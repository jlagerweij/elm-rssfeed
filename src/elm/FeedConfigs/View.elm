module FeedConfigs.View exposing (viewFeedItemsInColumn, viewFeeds)

import FeedConfigs.Types exposing (FeedConfig)
import FeedItem exposing (viewFeed)
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)


viewFeeds : List FeedConfig -> Html msg
viewFeeds feedConfigList =
    div [ class "dt dt--fixed sans-serif" ]
        [ viewFeedItemsInColumn "left" feedConfigList
        , viewFeedItemsInColumn "middle" feedConfigList
        , viewFeedItemsInColumn "right" feedConfigList
        ]


viewFeedItemsInColumn : String -> List FeedConfig -> Html msg
viewFeedItemsInColumn columnName feedConfigList =
    div [ class "dtc pv4 pl3", id columnName ]
        (feedConfigList
            |> List.filter (\feedConfig -> feedConfig.location == columnName)
            |> List.map (\feedConfig -> viewFeed (Maybe.withDefault feedConfig.id feedConfig.title) feedConfig.items)
        )
