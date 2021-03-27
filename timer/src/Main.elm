module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Events as Events
import Random
import Styles
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = always init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = ClickedStart
    | ClickedStop
    | ClickedReset
    | Tick Time.Posix
    | ClickedRandomize
    | GotNewTimeLimit Int


type alias Model =
    { timeLimit : Int
    , currentTime : Int
    , isRunning : Bool
    }


defaultTimeLimit : Int
defaultTimeLimit =
    30


init : ( Model, Cmd Msg )
init =
    ( { timeLimit = defaultTimeLimit
      , currentTime = defaultTimeLimit
      , isRunning = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedStart ->
            ( { model | isRunning = True }
            , Cmd.none
            )

        ClickedStop ->
            ( { model | isRunning = False }
            , Cmd.none
            )

        ClickedReset ->
            init

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

        ClickedRandomize ->
            ( model
            , Random.generate GotNewTimeLimit (Random.int 1 60)
            )

        GotNewTimeLimit timeLimit ->
            ( { model | currentTime = timeLimit, timeLimit = timeLimit }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.isRunning then
        Time.every 1000 Tick

    else
        Sub.none


view : Model -> Html Msg
view model =
    Html.div Styles.containerStyle
        [ viewTime model
        , viewButtons model
        ]


viewTime : Model -> Html Msg
viewTime model =
    Html.div Styles.timeStyle
        [ Html.text <| String.fromInt model.currentTime ]


viewButtons : Model -> Html Msg
viewButtons model =
    if model.isRunning then
        Html.div [] [ viewButton "Stop" ClickedStop ]

    else
        Html.div []
            [ viewButton "Start" ClickedStart
            , viewButton "Reset" ClickedReset
            , viewButton "Randomize" ClickedRandomize
            ]


viewButton : String -> Msg -> Html Msg
viewButton buttonLabel msg =
    Html.button (Styles.buttonStyle ++ [ Events.onClick msg ])
        [ Html.text buttonLabel ]
