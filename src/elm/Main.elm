module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, target, id)
import Styling.Css as Css
import Styling.HtmlCss exposing (class, nClass, bClass)


main : Html a
main =
    view


feedEntryView : Html a
feedEntryView =
    li [] [ a [ href "test", target "_blank" ] [ text "click me too" ] ]


feedBoxView : Html a
feedBoxView =
    div [ class [ Css.Box ] [] ]
        [ div [ class [ Css.Header ] [] ]
            [ h1 [] [ text "header" ] ]
        , div [ class [ Css.RssFeedClass ] [] ]
            [ ul []
                [ feedEntryView
                , feedEntryView
                , feedEntryView
                , feedEntryView
                , feedEntryView
                , feedEntryView
                , feedEntryView
                , feedEntryView
                , feedEntryView
                , feedEntryView
                , feedEntryView
                ]
            ]
        ]


view : Html a
view =
    div [ class [ Css.Feeder ] [ "pure-g" ] ]
        [ div [ class [ Css.Column ] [ "pure-u-1-3" ], id "left" ]
            [ feedBoxView
            , feedBoxView
            , feedBoxView
            , feedBoxView
            ]
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
