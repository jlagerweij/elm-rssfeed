module App exposing (..)

import FeedBox exposing (Item, feedBoxView, feedBoxView1)
import Html exposing (..)
import Html.Attributes exposing (href, id, target)
import Http
import Json.Decode exposing (Decoder, decodeValue, field, list, maybe, nullable, string, succeed, value)
import Json.Decode.Extra exposing ((|:))
import RemoteData exposing (RemoteData(Failure), RemoteData(Loading), RemoteData(NotAsked), RemoteData(Success), WebData)
import Styling.Css as Css
import Styling.HtmlCss exposing (bClass, class, nClass)


type alias Model =
    { feeds : WebData (List FeedConfig)
    }


init : ( Model, Cmd Msg )
init =
    ( Model RemoteData.Loading, getFeedConfigs )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = FeedConfigsResponse (WebData (List FeedConfig))
    | SingleFeedResponse FeedConfig (WebData (List FeedItem))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FeedConfigsResponse feedConfigsWebData ->
            case feedConfigsWebData of
                Success feeds ->
                    ( { model | feeds = feedConfigsWebData }
                    , getFeeds feeds
                    )

                _ ->
                    ( model, Cmd.none )

        SingleFeedResponse feedConfig singleFeedWebData ->
            case singleFeedWebData of
                Success feedItems ->
                    case model.feeds of
                        Success _ ->
                            let
                                x =
                                    RemoteData.map (\feedConfigs -> updateFeedConfigs feedConfig.id singleFeedWebData feedConfigs) model.feeds
                            in
                                ( { model | feeds = x }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


updateFeedConfigs : String -> WebData (List FeedItem) -> List FeedConfig -> List FeedConfig
updateFeedConfigs feedConfigId feedItemList feedConfigs =
    List.map (\feedConfig -> updateFeedItems feedConfigId feedItemList feedConfig) feedConfigs


updateFeedItems : String -> WebData (List FeedItem) -> FeedConfig -> FeedConfig
updateFeedItems feedConfigId feedItemList feedConfig =
    if feedConfig.id == feedConfigId then
        { feedConfig | items = Just feedItemList }
    else
        feedConfig



--


type alias FeedItem =
    { title : String
    , link : String
    }


getFeeds : List FeedConfig -> Cmd Msg
getFeeds feedConfigs =
    feedConfigs
        |> List.map (\f -> getFeed f)
        |> Cmd.batch


getFeed : FeedConfig -> Cmd Msg
getFeed feedConfig =
    Http.get ("/api/" ++ feedConfig.id ++ ".json") decodeSingleFeed
        |> RemoteData.sendRequest
        |> Cmd.map (SingleFeedResponse feedConfig)


decodeSingleFeed : Decoder (List FeedItem)
decodeSingleFeed =
    Json.Decode.list decodeSingleFeedItem


decodeSingleFeedItem : Decoder FeedItem
decodeSingleFeedItem =
    succeed FeedItem
        |: field "title" string
        |: field "link" string



--
-- FeedConfig


type alias FeedConfig =
    { id : String
    , url : String
    , items : Maybe (WebData (List FeedItem))
    }


getFeedConfigs : Cmd Msg
getFeedConfigs =
    Http.get "/api/feeds.json" decodeFeedConfigs
        |> RemoteData.sendRequest
        |> Cmd.map FeedConfigsResponse


decodeFeedConfigs : Decoder (List FeedConfig)
decodeFeedConfigs =
    Json.Decode.list decodeFeedConfig


decodeFeedConfig : Decoder FeedConfig
decodeFeedConfig =
    succeed FeedConfig
        |: field "id" string
        |: field "url" string
        |: maybe (field "items" (succeed (RemoteData.NotAsked)))


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
