module Feeds exposing (..)

import Articles
import Feeds.Feed exposing (Feed)
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)


view : List Feed -> Html msg
view feeds =
    div [ class "dt dt--fixed sans-serif" ]
        [ viewInColumn "left" feeds
        , viewInColumn "middle" feeds
        , viewInColumn "right" feeds
        ]


viewInColumn : String -> List Feed -> Html msg
viewInColumn columnName feeds =
    div [ class "dtc pv4 pl3", id columnName ]
        (feeds
            |> List.filter (\feed -> feed.location == columnName)
            |> List.map (\feed -> Articles.view (Maybe.withDefault feed.id feed.title) feed.items)
        )
