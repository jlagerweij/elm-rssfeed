module Articles exposing (view)

import Feeds.Article exposing (Article, ArticlesWebData)
import Html exposing (..)
import Html.Attributes exposing (class, href, target)
import Html.Parser
import Html.Parser.Util
import RemoteData exposing (RemoteData(..))


view : String -> ArticlesWebData -> Html a
view name articles =
    div []
        [ div []
            [ h1 [ class "f6 moon-gray code" ] [ text name ] ]
        , div []
            [ viewArticles articles
            ]
        ]


viewArticles : ArticlesWebData -> Html a
viewArticles articlesWebData =
    case articlesWebData of
        Success articles ->
            ul [ class "list pl0" ]
                (List.map (\article -> viewArticle article) articles)

        _ ->
            ul [] []


viewArticle : Article -> Html a
viewArticle article =
    let
        escapedTitle =
            article.title
                |> String.replace "&quot;" "'"
                |> String.replace "&euml;" "ë"

        t =
            case Html.Parser.run article.title of
                Ok x ->
                    Html.Parser.Util.toVirtualDom x

                Err _ ->
                    [ text escapedTitle ]
    in
    li [ class "b--dashed b--white-05 bb br-0 bl-0 bt-0 mb2" ]
        [ a [ class "no-underline silver f7 avenir ", href article.link, target "_blank" ] t
        ]
