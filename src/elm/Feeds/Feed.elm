module Feeds.Feed exposing (..)

import Api
import Api.Endpoint as Endpoint
import Feeds.Article exposing (ArticlesWebData)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData exposing (WebData)



-- TYPES


type alias Feed =
    { id : String
    , title : Maybe String
    , url : String
    , location : String
    , items : Maybe ArticlesWebData
    }


type alias FeedsWebData =
    WebData (List Feed)



-- LIST


list : Http.Request (List Feed)
list =
    Decode.list decodeFeed
        |> Api.get Endpoint.feeds



-- SERIALIZATION


decodeFeed : Decoder Feed
decodeFeed =
    Decode.succeed Feed
        |> required "id" Decode.string
        |> optional "title" (Decode.nullable Decode.string) Nothing
        |> required "url" Decode.string
        |> required "location" Decode.string
        |> optional "items" (Decode.succeed (Maybe.Just RemoteData.NotAsked)) (Maybe.Just RemoteData.NotAsked)
