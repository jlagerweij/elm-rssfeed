module Articles exposing (view)

import Feeds.Article exposing (Article, ArticlesWebData)
import Html exposing (..)
import Html.Attributes exposing (class, href, target)
import RemoteData exposing (RemoteData(..))


view : String -> Maybe ArticlesWebData -> Html a
view name maybeItems =
    div []
        [ div []
            [ h1 [ class "f6 tweakers-red" ] [ text name ] ]
        , div []
            [ viewMaybeFeedItem maybeItems
            ]
        ]


viewMaybeFeedItem : Maybe ArticlesWebData -> Html a
viewMaybeFeedItem maybeItems =
    case maybeItems of
        Just items ->
            case items of
                Success feedItems ->
                    ul [ class "list pl0" ]
                        (List.map (\item -> viewFeedItem item) feedItems)

                _ ->
                    ul [] []

        _ ->
            ul [] []


viewFeedItem : Article -> Html a
viewFeedItem item =
    let
        decodedTitle =
            item.title
                |> String.replace "&quot;" "'"
                |> String.replace "&euml;" "ë"
    in
    li [ class "bb b--light-gray mb2" ]
        [ a [ class "no-underline dark-blue f7 ", href item.link, target "_blank" ] [ text decodedTitle ]
        ]
