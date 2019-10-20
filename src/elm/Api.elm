module Api exposing (..)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Error, Expect)
import Json.Decode exposing (Decoder, Value)


get : Endpoint -> (Result Error a -> msg) -> Decoder a -> Cmd msg
get url toMsg decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson toMsg decoder
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }
