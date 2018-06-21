module FeedItem exposing (..)

import FeedItem.Types exposing (FeedItem)
import Html exposing (..)
import Html.Attributes exposing (href, id, target)
import RemoteData exposing (RemoteData(Success), WebData)
import Styling.Css exposing (tweakers_red)
import Tachyons exposing (classes)
import Tachyons.Classes exposing (b__light_gray, bb, dark_blue, dark_red, f6, list, mb2, no_underline, pl0)


viewFeed : String -> Maybe (WebData (List FeedItem)) -> Html a
viewFeed name maybeItems =
    div [ classes [] ]
        [ div []
            [ h1 [ classes [ f6, tweakers_red ] ] [ text name ] ]
        , div []
            [ viewMaybeFeedItem maybeItems
            ]
        ]


viewMaybeFeedItem : Maybe (WebData (List FeedItem)) -> Html a
viewMaybeFeedItem maybeItems =
    case maybeItems of
        Just items ->
            case items of
                Success feedItems ->
                    ul [ classes [ list, pl0 ] ]
                        (List.map (\item -> viewFeedItem item) feedItems)

                _ ->
                    ul [] []

        _ ->
            ul [] []


viewFeedItem : FeedItem -> Html a
viewFeedItem item =
    li [ classes [ bb, b__light_gray, mb2 ] ]
        [ a [ classes [ no_underline, dark_blue, f6 ], href item.link, target "_blank" ] [ text item.title ]
        ]
