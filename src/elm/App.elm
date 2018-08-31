module App exposing (Model, Msg(..), decodeFeedConfig, decodeFeedConfigs, decodeSingleFeed, decodeSingleFeedItem, getFeed, getFeedConfigs, getFeeds, init, subscriptions, update, updateFeedConfigs, updateFeedItems, view)

import Browser
import Browser.Navigation as Nav
import FeedConfigs.Types exposing (FeedConfig, FeedConfigListWebData)
import FeedConfigs.View exposing (viewFeeds)
import FeedItem.Types exposing (FeedItem, FeedItemListWebData)
import Html exposing (..)
import Http
import Json.Decode exposing (Decoder, decodeValue, field, list, maybe, nullable, string, succeed, value)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)

import RemoteData exposing (RemoteData(..), WebData)
import Url


type alias Model ={ feedConfigWebData : FeedConfigListWebData
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( Model RemoteData.Loading, getFeedConfigs )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = FeedConfigsResponse FeedConfigListWebData
    | SingleFeedResponse FeedConfig FeedItemListWebData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FeedConfigsResponse feedConfigsWebData ->
            case feedConfigsWebData of
                Success feeds ->
                    ( { model | feedConfigWebData = feedConfigsWebData }
                    , getFeeds feeds
                    )

                _ ->
                    ( model, Cmd.none )

        SingleFeedResponse feedConfig singleFeedWebData ->
            case singleFeedWebData of
                Success feedItems ->
                    let
                        newfeedConfigWebData =
                            RemoteData.map (updateFeedConfigs feedConfig.id singleFeedWebData) model.feedConfigWebData
                    in
                    ( { model | feedConfigWebData = newfeedConfigWebData }, Cmd.none )

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


getFeeds : List FeedConfig -> Cmd Msg
getFeeds feedConfigs =
    feedConfigs
        |> List.map getFeed
        |> Cmd.batch


getFeed : FeedConfig -> Cmd Msg
getFeed feedConfig =
    Http.get ("api/feed-" ++ feedConfig.id ++ ".json") decodeSingleFeed
        |> RemoteData.sendRequest
        |> Cmd.map (SingleFeedResponse feedConfig)


decodeSingleFeed : Decoder (List FeedItem)
decodeSingleFeed =
    Json.Decode.list decodeSingleFeedItem


decodeSingleFeedItem : Decoder FeedItem
decodeSingleFeedItem =
    succeed FeedItem
        |> required "title" string
        |> required "link" string



--
-- FeedConfig


getFeedConfigs : Cmd Msg
getFeedConfigs =
    Http.get "api/feeds.json" decodeFeedConfigs
        |> RemoteData.sendRequest
        |> Cmd.map FeedConfigsResponse


decodeFeedConfigs : Decoder (List FeedConfig)
decodeFeedConfigs =
    Json.Decode.list decodeFeedConfig


decodeFeedConfig : Decoder FeedConfig
decodeFeedConfig =
    succeed FeedConfig
        |> required "id" string
        |> required "url" string
        |> required "location" string
        |> optional "items" (succeed (Maybe.Just RemoteData.NotAsked)) (Maybe.Just RemoteData.NotAsked)


view : Model -> Html msg
view model =
    case model.feedConfigWebData of
        NotAsked ->
            text "Initializing"

        Loading ->
            text "Loading..."

        Failure err ->
            text ("Error:" ++ "TODO show err")

        Success feeds ->
            viewFeeds feeds
