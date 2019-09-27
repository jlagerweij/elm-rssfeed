module Articles exposing (view)

import Feeds.Article exposing (Article, ArticlesWebData)
import Html exposing (..)
import Html.Attributes exposing (class, href, target)
import RemoteData exposing (RemoteData(..))


view : String -> ArticlesWebData -> Html a
view name articles =
    div []
        [ div []
            [ h1 [ class "f6 tweakers-red" ] [ text name ] ]
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
        decodedTitle =
            article.title
                |> String.replace "&quot;" "'"
                |> String.replace "&euml;" "ë"
    in
    li [ class "bb b--light-gray mb2" ]
        [ a [ class "no-underline dark-blue f7 ", href article.link, target "_blank" ] [ text decodedTitle ]
        ]