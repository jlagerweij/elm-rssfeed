port module Stylesheets exposing (..)

import Styling.Css
import Css.File exposing (..)


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure [ ( "styles.css", compile [ Styling.Css.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles
