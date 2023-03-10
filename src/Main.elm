port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (preventDefaultOn)
import Json.Decode as D
import Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TransitionStart maybeRoute ->
            ( { model
                | transition = maybeRoute |> Maybe.map To
              }
            , Cmd.none
            )

        UrlChanged maybeRoute ->
            case maybeRoute of
                Just route ->
                    ( { model
                        | route = route
                        , transition = Just (From model.route)
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        PushUrl url ->
            ( { model | transition = Nothing }, pushUrl url )


type Transition
    = To Route
    | From Route


navbar : Html Msg
navbar =
    nav [ class "main-header" ]
        [ link (PushUrl "/")
            [ href "/" ]
            [ text "Home"
            ]
        ]


view : Model -> Html Msg
view model =
    let
        isToOrFrom route =
            model.transition == Just (From route) || (model.transition == Just (To route))
    in
    div []
        [ navbar
        , case model.route of
            Index ->
                div
                    []
                    ([ "1", "2", "3" ]
                        |> List.map
                            (\index ->
                                let
                                    asterisk =
                                        if isToOrFrom (Detail index) then
                                            --"*"
                                            ""

                                        else
                                            ""
                                in
                                h2
                                    (if isToOrFrom (Detail index) then
                                        [ transitionName Title ]

                                     else
                                        []
                                    )
                                    [ link (PushUrl ("/" ++ index))
                                        [ href ("/" ++ index) ]
                                        [ text <| "Item " ++ index ++ asterisk ]
                                    ]
                            )
                    )

            Detail id ->
                div []
                    [ h2
                        [ transitionName Title ]
                        [ text <| "Item " ++ id ]
                    ]
        ]


type TransitionElement
    = Title


transitionName : TransitionElement -> Attribute msg
transitionName element =
    class
        (case element of
            Title ->
                "title-element"
        )


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
    | TransitionStart (Maybe Route)
    | PushUrl String


type Route
    = Index
    | Detail String


type alias Model =
    { route : Route
    , transition : Maybe Transition
    }


init : String -> ( Model, Cmd Msg )
init locationHref =
    ( { route = locationHref |> locationHrefToRoute |> Maybe.withDefault Index
      , transition = Nothing
      }
    , Cmd.none
    )


link : msg -> List (Attribute msg) -> List (Html msg) -> Html msg
link href attrs children =
    a (preventDefaultOn "click" (D.succeed ( href, True )) :: attrs) children


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onTransitionStart (locationHrefToRoute >> TransitionStart)
        , onUrlChange (locationHrefToRoute >> UrlChanged)
        ]


port onTransitionStart : (String -> msg) -> Sub msg


port onUrlChange : (String -> msg) -> Sub msg


port pushUrl : String -> Cmd msg


pathToRoute : String -> Maybe Route
pathToRoute path =
    case path |> String.split "/" |> List.filter (not << String.isEmpty) of
        [] ->
            Just Index

        [ id ] ->
            Just (Detail id)

        _ ->
            Nothing


locationHrefToRoute : String -> Maybe Route
locationHrefToRoute locationHref =
    locationHref
        |> Url.fromString
        |> Maybe.andThen
            (.path >> pathToRoute)
