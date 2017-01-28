module Styling.HtmlCss exposing (nClass, bClass, class, cssPrefix)

import Css.Helpers exposing (toCssIdentifier, identifierToString)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr


cssPrefix : String
cssPrefix =
    "rss"


nClass : List class -> Attribute msg
nClass nList =
    nList
        |> List.map (identifierToString cssPrefix)
        |> String.join " "
        |> Attr.class


bClass : List String -> Attribute msg
bClass bList =
    bList
        |> String.join " "
        |> Attr.class


class : List class -> List String -> Attribute msg
class nList bList =
    let
        nClasses =
            nList
                |> List.map (identifierToString cssPrefix)
                |> String.join " "

        bClasses =
            bList
                |> String.join " "
    in
        Attr.class (nClasses ++ " " ++ bClasses)
