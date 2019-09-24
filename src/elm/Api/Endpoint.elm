module Api.Endpoint exposing (..)

import Http
import Url.Builder exposing (QueryParameter)


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , withCredentials : Bool
    }
    -> Http.Request a
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , withCredentials = config.withCredentials
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
