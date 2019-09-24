module App exposing (Model, Msg(..), getFeed, getFeeds, init, subscriptions, update, updateFeedConfigs, updateFeedItems, view)

import Feeds
import Feeds.Article as Articles exposing (Article, ArticlesWebData)
import Feeds.Feed as Feeds exposing (Feed, FeedsWebData)
import Html exposing (..)
import Html.Attributes exposing (class)
import Http exposing (Error(..))
import RemoteData exposing (RemoteData(..), WebData)


type alias Model =
    { feedConfigWebData : FeedsWebData
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model RemoteData.Loading
    , Feeds.list
        |> RemoteData.sendRequest
        |> Cmd.map FeedsResponse
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = FeedsResponse FeedsWebData
    | SingleFeedResponse Feed ArticlesWebData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FeedsResponse feedConfigsWebData ->
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


updateFeedConfigs : String -> ArticlesWebData -> List Feed -> List Feed
updateFeedConfigs feedConfigId feedItemList feedConfigs =
    feedConfigs
        |> List.map
            (\feedConfig ->
                updateFeedItems feedConfigId feedItemList feedConfig
            )


updateFeedItems : String -> ArticlesWebData -> Feed -> Feed
updateFeedItems feedConfigId feedItemList feedConfig =
    if feedConfig.id == feedConfigId then
        { feedConfig | items = feedItemList }

    else
        feedConfig



--


getFeeds : List Feed -> Cmd Msg
getFeeds feedConfigs =
    feedConfigs
        |> List.map getFeed
        |> Cmd.batch


getFeed : Feed -> Cmd Msg
getFeed feedConfig =
    Articles.list feedConfig.id
        |> RemoteData.sendRequest
        |> Cmd.map (SingleFeedResponse feedConfig)


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
            Feeds.view feeds


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
