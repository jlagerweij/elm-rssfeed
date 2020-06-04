module Feeds.Feed exposing (..)

import Api
import Api.Endpoint as Endpoint
import Feeds.Article exposing (ArticlesWebData)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData exposing (WebData)



-- TYPES


type alias Config =
    { left : List Feed
    , middle : List Feed
    , right : List Feed
    }


type alias Feed =
    { id : String
    , title : Maybe String
    , url : String
    , location : String
    , items : ArticlesWebData
    }


type alias ConfigWebData =
    WebData Config



-- LIST


list : (Result Http.Error Config -> msg) -> Cmd msg
list toMsg =
    Api.get
        Endpoint.feeds
        toMsg
        decodeFeeds



-- SERIALIZATION


decodeFeeds : Decoder Config
decodeFeeds =
    Decode.succeed Config
        |> required "left" (Decode.list (decodeFeed "left"))
        |> required "middle" (Decode.list (decodeFeed "middle"))
        |> required "right" (Decode.list (decodeFeed "right"))


decodeFeed : String -> Decoder Feed
decodeFeed location =
    Decode.succeed Feed
        |> required "id" Decode.string
        |> optional "title" (Decode.nullable Decode.string) Nothing
        |> required "url" Decode.string
        |> optional "location" Decode.string location
        |> optional "items" (Decode.succeed RemoteData.NotAsked) RemoteData.NotAsked
