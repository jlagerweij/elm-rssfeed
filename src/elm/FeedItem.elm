module FeedItem exposing (viewFeed, viewFeedItem, viewMaybeFeedItem)

import FeedItem.Types exposing (FeedItem)
import Html exposing (..)
import Html.Attributes exposing (class, href, target)
import RemoteData exposing (RemoteData(..), WebData)


viewFeed : String -> Maybe (WebData (List FeedItem)) -> Html a
viewFeed name maybeItems =
    div []
        [ div []
            [ h1 [ class "f6 tweakers-red" ] [ text name ] ]
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
                    ul [ class "list pl0" ]
                        (List.map (\item -> viewFeedItem item) feedItems)

                _ ->
                    ul [] []

        _ ->
            ul [] []


viewFeedItem : FeedItem -> Html a
viewFeedItem item =
    let
        decodedTitle =
            item.title
                |> String.replace "&quot;" "'"
                |> String.replace "&euml;" "ë"
    in
    li [ class "bb b--light-gray mb2" ]
        [ a [ class "no-underline dark-blue f7 ", href item.link, target "_blank" ] [ text decodedTitle ]
        ]
