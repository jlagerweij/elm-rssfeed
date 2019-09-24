module App exposing (Model, Msg(..), decodeFeedConfig, decodeFeedConfigs, decodeSingleFeed, decodeSingleFeedItem, getFeed, getFeedConfigs, getFeeds, init, subscriptions, update, updateFeedConfigs, updateFeedItems, view)

import FeedConfigs.Types exposing (FeedConfig, FeedConfigListWebData)
import FeedConfigs.View exposing (viewFeeds)
import FeedItem.Types exposing (FeedItem, FeedItemListWebData)
import Html exposing (..)
import Html.Attributes exposing (class)
import Http exposing (Error(..))
import Json.Decode exposing (Decoder, nullable, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData exposing (RemoteData(..), WebData)


type alias Model =
    { feedConfigWebData : FeedConfigListWebData
    }


init : () -> ( Model, Cmd Msg )
init _ =
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
                    ( { model | feedConfigWebData = feedConfigsWebData }, Cmd.none )

        SingleFeedResponse feedConfig singleFeedWebData ->
            case singleFeedWebData of
                Success _ ->
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
        |> optional "title" (nullable string) Nothing
        |> required "url" string
        |> required "location" string
        |> optional "items" (succeed (Maybe.Just RemoteData.NotAsked)) (Maybe.Just RemoteData.NotAsked)


view : Model -> Html msg
view model =
    case model.feedConfigWebData of
        NotAsked ->
            text "Initializing"

        Loading ->
            text "Loadingss..."

        Failure err ->
            viewError err

        Success feeds ->
            viewFeeds feeds


viewError : Http.Error -> Html msg
viewError err =
    div [ class "bg-red" ] [ text (errorToString err) ]


errorToString : Http.Error -> String
errorToString error =
    case error of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Timeout ->
            "Unable to reach the server, try again"

        NetworkError ->
            "Unable to reach the server, check your network connection"

        BadStatus errorMessage ->
            case errorMessage.status.code of
                500 ->
                    "The server had a problem, try again later" ++ errorMessage.body

                400 ->
                    "Verify your information and try again"

                _ ->
                    "Unknown error"

        BadPayload message _ ->
            message
