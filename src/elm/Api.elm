module Api exposing (..)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode exposing (Decoder, Value)


get : Endpoint -> Decoder a -> Http.Request a
get url decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson decoder
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        , withCredentials = False
        }


put : Endpoint -> Body -> Decoder a -> Http.Request a
put url body decoder =
    Endpoint.request
        { method = "PUT"
        , url = url
        , expect = Http.expectJson decoder
        , headers = []
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }


post : Endpoint -> Body -> Decoder a -> Http.Request a
post url body decoder =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = Http.expectJson decoder
        , headers = []
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }


delete : Endpoint -> Body -> Decoder a -> Http.Request a
delete url body decoder =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = Http.expectJson decoder
        , headers = []
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }
