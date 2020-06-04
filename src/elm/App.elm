module App exposing (Model, Msg(..), getFeeds, init, subscriptions, update, updateFeedConfigs, updateFeedItems, view)

import Feeds
import Feeds.Article as Articles exposing (Article, ArticlesWebData)
import Feeds.Feed as Feeds exposing (Config, ConfigWebData, Feed)
import Html exposing (..)
import Html.Attributes exposing (class)
import Http exposing (Error(..))
import RemoteData exposing (RemoteData(..), WebData)


type alias Model =
    { feedConfigWebData : ConfigWebData
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model RemoteData.Loading
    , Feeds.list (RemoteData.fromResult >> FeedsResponse)
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = FeedsResponse ConfigWebData
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


updateFeedConfigs : String -> ArticlesWebData -> Config -> Config
updateFeedConfigs feedConfigId articles feedConfigs =
    let
        updateFeed =
            List.map
                (\feedConfig ->
                    updateFeedItems feedConfigId articles feedConfig
                )
    in
    { left = feedConfigs.left |> updateFeed
    , middle = feedConfigs.middle |> updateFeed
    , right = feedConfigs.right |> updateFeed
    }


updateFeedItems : String -> ArticlesWebData -> Feed -> Feed
updateFeedItems feedConfigId feedItemList feedConfig =
    if feedConfig.id == feedConfigId then
        { feedConfig | items = feedItemList }

    else
        feedConfig



--


getFeeds : Config -> Cmd Msg
getFeeds feedConfigs =
    (feedConfigs.left ++ feedConfigs.middle ++ feedConfigs.right)
        |> List.map (\feed -> Articles.list (RemoteData.fromResult >> SingleFeedResponse feed) feed.id)
        |> Cmd.batch


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

        BadStatus statusCode ->
            case statusCode of
                500 ->
                    "The server had a problem, try again later"

                400 ->
                    "Verify your information and try again"

                _ ->
                    "Unknown error"

        BadBody message ->
            message
