module Api.Endpoint exposing (..)

import Http
import Url.Builder exposing (QueryParameter)


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { method : String
    , headers : List Http.Header
    , url : Endpoint
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd msg
request config =
    Http.request
        { method = config.method
        , headers = config.headers
        , body = config.body
        , expect = config.expect
        , timeout = config.timeout
        , url = unwrap config.url
        , tracker = config.tracker
        }


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


type Endpoint
    = Endpoint String


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Url.Builder.relative
        ("api" :: paths)
        queryParams
        |> Endpoint



-- ENDPOINTS


feeds : Endpoint
feeds =
    url [ "feeds.json" ] []


articles : String -> Endpoint
articles id =
    url [ "feed-" ++ id ++ ".json" ] []
