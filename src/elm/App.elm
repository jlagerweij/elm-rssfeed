module App exposing (..)

import FeedBox exposing (Item, feedBoxView, feedBoxView1)
import Html exposing (..)
import Html.Attributes exposing (href, target, id)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, requiredAt)
import RemoteData exposing (RemoteData(Failure, Loading, NotAsked, Success), WebData)
import Styling.Css as Css
import Styling.HtmlCss exposing (class, nClass, bClass)


type alias Model =
    { feeds : WebData (List Feeds)
    }


init : ( Model, Cmd Msg )
init =
    ( Model RemoteData.NotAsked, getFeeds )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = FeedsResponse (WebData (List Feeds))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FeedsResponse response ->
            ( { model | feeds = response }
            , Cmd.none
            )



-- Feeds


type alias Feeds =
    { id : String
    , url : String
    }


getFeeds : Cmd Msg
getFeeds =
    Http.get "/api/feeds.json" decodeFeedsList
        |> RemoteData.sendRequest
        |> Cmd.map FeedsResponse


decodeFeed : Decoder Feeds
decodeFeed =
    decode Feeds
        |> requiredAt [ "id" ] string
        |> requiredAt [ "url" ] string


decodeFeedsList : Decoder (List Feeds)
decodeFeedsList =
    Json.Decode.list decodeFeed


view : Model -> Html msg
view model =
    case model.feeds of
        NotAsked ->
            text "Initializing"

        Loading ->
            text "Loading..."

        Failure err ->
            text ("Error:" ++ toString err)

        Success feeds ->
            viewFeeds feeds


viewFeeds : List Feeds -> Html msg
viewFeeds feedsList =
    div [ class [ Css.Feeder ] [ "pure-g" ] ]
        [ div [ class [ Css.Column ] [ "pure-u-1-3" ], id "left" ]
            (List.map (\feed -> feedBoxView1 feed.id []) feedsList)
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
