module Home exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attributes


type Msg
    = NoOp


type alias Model =
    ()


init : Model
init =
    ()


update : Msg -> Model -> Model
update NoOp model =
    model


view : Model -> Html Msg
view _ =
    Html.div [ Attributes.class "page" ] [ Html.text "Home" ]
