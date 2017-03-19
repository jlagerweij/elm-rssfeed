module App exposing (..)

import FeedConfigs exposing (FeedConfigList, viewFeeds)
import Html exposing (..)
import Http
import Json.Decode exposing (Decoder, decodeValue, field, list, maybe, nullable, string, succeed, value)
import Json.Decode.Extra exposing ((|:))
import RemoteData exposing (RemoteData(Failure), RemoteData(Loading), RemoteData(NotAsked), RemoteData(Success), WebData)


type alias Model =
    { feeds : FeedConfigList
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
