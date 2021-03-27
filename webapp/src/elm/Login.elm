module Login exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser.Navigation as BrowserNavigation
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Ports
import Requests


type Msg
    = InsertedUsername String
    | InsertedPassword String
    | ClickedSubmit
    | GotToken (Result Http.Error String)


type alias Model =
    { username : String
    , password : String
    , failed : Bool
    }


init : Model
init =
    { username = ""
    , password = ""
    , failed = False
    }


update : BrowserNavigation.Key -> (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update key wrapMsg msg model =
    case msg of
        InsertedUsername username ->
            ( { model | username = username }
            , Cmd.none
            )

        InsertedPassword password ->
            ( { model | password = password }
            , Cmd.none
            )

        ClickedSubmit ->
            if String.isEmpty model.username || String.isEmpty model.password then
                ( model
                , Cmd.none
                )

            else
                ( model
                , Requests.fetchToken model (wrapMsg << GotToken)
                )

        GotToken result ->
            case result of
                Ok token ->
                    ( model
                    , Cmd.batch
                        [ BrowserNavigation.pushUrl key "/"
                        , Ports.saveToken token
                        ]
                    )

                Err _ ->
                    ( { model | failed = True }
                    , Cmd.none
                    )


view : Model -> Html Msg
view model =
    let
        error =
            if model.failed then
                Html.div [ Attributes.class "login-error" ]
                    [ Html.text "Invalid credentials" ]

            else
                Html.text ""
    in
    Html.form [ Events.onSubmit ClickedSubmit, Attributes.class "page Login" ]
        [ error
        , Html.label [] [ Html.text "Username" ]
        , Html.input
            [ Attributes.type_ "text"
            , Attributes.value model.username
            , Events.onInput InsertedUsername
            ]
            []
        , Html.label [] [ Html.text "Password" ]
        , Html.input
            [ Attributes.type_ "password"
            , Attributes.value model.password
            , Events.onInput InsertedPassword
            ]
            []
        , Html.button [ Attributes.type_ "submit" ]
            [ Html.text "Log In" ]
        ]
