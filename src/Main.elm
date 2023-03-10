port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (preventDefaultOn)
import Json.Decode as D
import Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged maybeRoute ->
            case maybeRoute of
                Just route ->
                    ( { model | route = route }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        PushUrl url ->
            ( model, pushUrl url )


view : Model -> Html Msg
view model =
    case model.route of
        Index ->
            div []
                ([ 1, 2, 3 ]
                    |> List.map
                        (\index ->
                            h2 []
                                [ link (PushUrl ("/" ++ String.fromInt index))
                                    [ href ("/" ++ String.fromInt index)
                                    ]
                                    [ text <| "Item " ++ String.fromInt index
                                    ]
                                ]
                        )
                )

        Detail id ->
            div []
                [ h1 [] [ text <| "Item " ++ id ] ]


main : Program String Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = UrlChanged (Maybe Route)
    | PushUrl String


type Route
    = Index
    | Detail String


type alias Model =
    { route : Route
    }


init : String -> ( Model, Cmd Msg )
init locationHref =
    ( { route = locationHref |> locationHrefToRoute |> Maybe.withDefault Index
      }
    , Cmd.none
    )


link : msg -> List (Attribute msg) -> List (Html msg) -> Html msg
link href attrs children =
    a (preventDefaultOn "click" (D.succeed ( href, True )) :: attrs) children


subscriptions : Model -> Sub Msg
subscriptions model =
    onUrlChange (locationHrefToRoute >> UrlChanged)


port onUrlChange : (String -> msg) -> Sub msg


port pushUrl : String -> Cmd msg


locationHrefToRoute : String -> Maybe Route
locationHrefToRoute locationHref =
    case Url.fromString locationHref of
        Nothing ->
            Nothing

        Just url ->
            case url.path |> String.split "/" |> List.filter (not << String.isEmpty) of
                [] ->
                    Just Index

                [ id ] ->
                    Just (Detail id)

                _ ->
                    Nothing
