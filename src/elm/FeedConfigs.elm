module FeedConfigs exposing (..)

import FeedBox exposing (feedBoxView)
import FeedItem exposing (FeedItem, viewFeed)
import Html exposing (..)
import Html.Attributes exposing (href, id, target)
import RemoteData exposing (RemoteData(Success), WebData)
import Styling.Css as Css
import Styling.HtmlCss exposing (bClass, class, nClass)


type alias FeedConfigList =
    WebData (List FeedConfig)


type alias FeedConfig =
    { id : String
    , url : String
    , items : Maybe (WebData (List FeedItem))
    }


viewFeeds : List FeedConfig -> Html msg
viewFeeds feedsList =
    div [ class [ Css.Feeder ] [ "pure-g" ] ]
        [ div [ class [ Css.Column ] [ "pure-u-1-3" ], id "left" ]
            (List.map (\feed -> viewFeed feed.id feed.items) feedsList)
        , div [ class [ Css.Column ] [ "pure-u-1-3" ], id "middle" ]
            [ feedBoxView
            , feedBoxView
            , feedBoxView
            , feedBoxView
            ]
        , div [ class [ Css.Column ] [ "pure-u-1-3" ], id "right" ]
            [ feedBoxView
            , feedBoxView
            , feedBoxView
            , feedBoxView
            ]
        ]
