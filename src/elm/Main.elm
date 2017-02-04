module Main exposing (..)

import Html exposing (..)
import App exposing (init, update, view)


main : Program Never App.Model App.Msg
main =
    Html.program
        { init = App.init
        , update = App.update
        , view = App.view
        , subscriptions = App.subscriptions
        }
