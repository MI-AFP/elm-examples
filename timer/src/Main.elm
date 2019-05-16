module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Random
import Styles
import Time


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = Start
    | Stop
    | Reset
    | Tick Time.Posix
    | Randomize
    | NewTimeLimit Int


type alias Model =
    { timeLimit : Int
    , currentTime : Int
    , isRunning : Bool
    }


defaultTimeLimit : Int
defaultTimeLimit =
    30


init : () -> ( Model, Cmd Msg )
init _ =
    ( { timeLimit = defaultTimeLimit
      , currentTime = defaultTimeLimit
      , isRunning = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Start ->
            ( { model | isRunning = True }, Cmd.none )

        Stop ->
            ( { model | isRunning = False }, Cmd.none )

        Reset ->
            init ()

        Tick _ ->
            let
                isRunning =
                    model.currentTime > 0

                currentTime =
                    if isRunning then
                        model.currentTime - 1

                    else
                        model.currentTime
            in
            ( { model
                | currentTime = currentTime
                , isRunning = currentTime > 0
              }
            , Cmd.none
            )

        Randomize ->
            ( model, Random.generate NewTimeLimit (Random.int 1 60) )

        NewTimeLimit timeLimit ->
            ( { model | currentTime = timeLimit, timeLimit = timeLimit }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.isRunning then
        Time.every 1000 Tick

    else
        Sub.none


view : Model -> Html Msg
view model =
    div Styles.containerStyle
        [ viewTime model
        , viewButtons model
        ]


viewTime : Model -> Html Msg
viewTime model =
    div Styles.timeStyle [ text <| String.fromInt model.currentTime ]


viewButtons : Model -> Html Msg
viewButtons model =
    if model.isRunning then
        div [] [ viewButton "Stop" Stop ]

    else
        div []
            [ viewButton "Start" Start
            , viewButton "Reset" Reset
            , viewButton "Randomize" Randomize
            ]


viewButton : String -> Msg -> Html Msg
viewButton buttonLabel msg =
    button (Styles.buttonStyle ++ [ onClick msg ]) [ text buttonLabel ]
