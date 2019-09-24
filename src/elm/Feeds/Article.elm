module Feeds.Article exposing (..)

import Api
import Api.Endpoint as Endpoint
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)



-- TYPES


type alias Article =
    { title : String
    , link : String
    }


type alias ArticlesWebData =
    WebData (List Article)



-- LIST


list : String -> Http.Request (List Article)
list feedId =
    Decode.list decodeArticle
        |> Api.get (Endpoint.articles feedId)



-- SERIALIZATION


decodeArticle : Decoder Article
decodeArticle =
    Decode.succeed Article
        |> required "title" Decode.string
        |> required "link" Decode.string
