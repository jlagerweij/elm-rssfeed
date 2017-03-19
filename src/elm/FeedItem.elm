module FeedItem exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, id, target)
import RemoteData exposing (RemoteData(Success), WebData)
import Styling.Css as Css
import Styling.HtmlCss exposing (bClass, class, nClass)


type alias FeedItemListWebData =
    WebData (List FeedItem)


type alias FeedItem =
    { title : String
    , link : String
    }


viewFeed : String -> Maybe (WebData (List FeedItem)) -> Html a
viewFeed name maybeItems =
    div [ class [ Css.Box ] [] ]
        [ div [ class [ Css.Header ] [] ]
            [ h1 [] [ text name ] ]
        , div [ class [ Css.RssFeedClass ] [] ]
            [ viewMaybeFeedItem maybeItems
            ]
        ]


viewMaybeFeedItem : Maybe (WebData (List FeedItem)) -> Html a
viewMaybeFeedItem maybeItems =
    case maybeItems of
        Just items ->
            case items of
                Success feedItems ->
                    ul []
                        (List.map (\item -> viewFeedItem item) feedItems)

                _ ->
                    ul [] []

        _ ->
            ul [] []


viewFeedItem : FeedItem -> Html a
viewFeedItem item =
    li [] [ Html.a [ href item.link, target "_blank" ] [ text item.title ] ]
