module Styling.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (a, body, button, h1, h2, h3, input, ul, li, p, select, table, td, th, tr)
import Css.Namespace exposing (namespace)
import Styling.HtmlCss exposing (cssPrefix)


type CssClasses
    = Feeder
    | Box
    | Column
    | Header
    | PullRight
    | RssFeedClass


css : Stylesheet
css =
    (stylesheet << namespace cssPrefix)
        [ body
            [ fontSize (px 13)
            , fontFamilies [ "Roboto Condensed", "Helvetica", "Arial", "Liberation Sans", "sans-serif" ]
            , backgroundColor mainBackgroundColor
            , color mainTextColor
            ]
        , (.) PullRight
            [ float right ]
        , (.) Feeder []
        , (.) Column
            [ width (pc 33.3)
            , descendants
                [ (.) Box
                    [ marginBottom (px 10)
                    , marginLeft (px 5)
                    , marginRight (px 5)
                    , backgroundColor mainBackgroundColor
                    , descendants
                        [ (.) Header
                            [ color (hex "b9133c")
                            , padding4 (px 3) (px 3) (px 3) (px 6)
                            , backgroundColor mainBackgroundColor
                            , descendants
                                [ h1
                                    [ fontSize (px 13)
                                    , fontWeight bold
                                    , margin (px 0)
                                    ]
                                ]
                            ]
                        , (.) RssFeedClass
                            [ descendants
                                [ a
                                    [ textDecoration none
                                    , color rssFeedClassLinkColor
                                    ]
                                , p
                                    [ padding (px 0)
                                    , margin (px 0)
                                    ]
                                , ul
                                    [ listStyle none
                                    , paddingLeft (px 5)
                                    ]
                                , li
                                    [ borderBottom3 (px 1) solid bottomColor
                                    , paddingTop (px 7)
                                    , paddingBottom (px 7)
                                    , paddingLeft (px 20)
                                    , textIndent (px -20)
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


mainBackgroundColor : Color
mainBackgroundColor =
    hex "ffffff"


mainTextColor : Color
mainTextColor =
    hex "000000"


rssFeedClassLinkColor : Color
rssFeedClassLinkColor =
    hex "014c93"


bottomColor : Color
bottomColor =
    hex "e8eaea"


boxHeaderColor : Color
boxHeaderColor =
    hex "b9133c"
