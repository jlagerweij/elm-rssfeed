module Main exposing (main)

import Json.Decode as Decode exposing (Value)
import App exposing (init, update, view)
import Browser
import Html exposing (..)


main : Program () App.Model App.Msg
main =
    Browser.element
        { init = App.init
        , update = App.update
        , view = App.view
        , subscriptions = App.subscriptions
        }
