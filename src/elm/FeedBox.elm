module FeedBox exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, target, id)
import RemoteData exposing (WebData)
import Styling.Css as Css
import Styling.HtmlCss exposing (class, nClass, bClass)


type alias Model =
    { feeds : WebData (List Item)
    }


type alias Item =
    { title : String
    , link : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model RemoteData.NotAsked, getItems )


type Msg
    = GetItems


getItems : Cmd Msg
getItems =
    Cmd.none


feedEntryView : Html a
feedEntryView =
    li [] [ a [ href "test", target "_blank" ] [ text "click me too" ] ]


feedItemView : Item -> Html a
feedItemView item =
    li [] [ a [ href item.link, target "_blank" ] [ text item.title ] ]


feedBoxView : Html a
feedBoxView =
    feedBoxView1 "header" [ Item "click me some more" "test" ]


feedBoxView1 : String -> List Item -> Html a
feedBoxView1 name items =
    div [ class [ Css.Box ] [] ]
        [ div [ class [ Css.Header ] [] ]
            [ h1 [] [ text name ] ]
        , div [ class [ Css.RssFeedClass ] [] ]
            [ ul []
                (List.map (\item -> feedItemView item) items)
            ]
        ]
