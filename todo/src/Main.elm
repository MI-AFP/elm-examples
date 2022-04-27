module Main exposing (main)

-- import Html.Attributes as Attributes
-- import Html.Events as Events
-- import Http
-- import Json.Decode as Decode
-- import Json.Encode as Encode

import Browser
import Html exposing (Html)
import Styles


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    {}


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}
    , Cmd.none
    )


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )


view : Model -> Html Msg
view _ =
    Html.div Styles.containerStyle
        [ Html.h1 [] [ Html.text "Todo list" ]
        , Html.text "TODO"
        ]
