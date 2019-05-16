module Main exposing (main)

import Browser exposing (Document)
import Form exposing (Form)
import Form.Error exposing (ErrorValue(..))
import Form.Input as Input
import Form.Validate as Validate exposing (..)
import Html exposing (..)
import Html.Attributes exposing (style, type_)
import Html.Events exposing (..)


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { personForm : Form CustomFormError Person
    }


type alias Person =
    { name : String
    , age : Int
    , favoriteColor : Color
    , favoriteFoods : List String
    }


type Color
    = Red
    | Yellow
    | Green
    | Blue
    | Purple


type CustomFormError
    = InvalidColor


initPersonForm : Form CustomFormError Person
initPersonForm =
    Form.initial [] personValidation


personValidation : Validation CustomFormError Person
personValidation =
    Validate.map4 Person
        (Validate.field "name" Validate.string)
        (Validate.field "age" Validate.int)
        (Validate.field "favoriteColor" colorValidation)
        (Validate.field "favoriteFoods" (Validate.list Validate.string))


colorValidation : Validation CustomFormError Color
colorValidation =
    Validate.string
        |> Validate.andThen
            (\value ->
                case value of
                    "Red" ->
                        Validate.succeed Red

                    "Yellow" ->
                        Validate.succeed Yellow

                    "Green" ->
                        Validate.succeed Green

                    "Blue" ->
                        Validate.succeed Blue

                    "Purple" ->
                        Validate.succeed Purple

                    _ ->
                        Validate.fail <| Validate.customError InvalidColor
            )


init : () -> ( Model, Cmd Msg )
init _ =
    ( { personForm = initPersonForm }
    , Cmd.none
    )



-- UPDATE


type Msg
    = FormMsg Form.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg formMsg ->
            case ( formMsg, Form.getOutput model.personForm ) of
                ( Form.Submit, Just form ) ->
                    let
                        _ =
                            Debug.log "Submit form" form
                    in
                    ( model, Cmd.none )

                _ ->
                    ( { model | personForm = Form.update personValidation formMsg model.personForm }
                    , Cmd.none
                    )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Form Example"
    , body =
        [ viewForm model.personForm |> Html.map FormMsg ]
    }


viewForm : Form CustomFormError Person -> Html Form.Msg
viewForm personForm =
    form [ onSubmit Form.Submit ]
        [ fieldset []
            [ legend [] [ text "Person" ]
            , viewTextInput personForm "name" "Name"
            , viewTextInput personForm "age" "Age"
            , viewSelectInput colorOptions personForm "favoriteColor" "Favorite Color"
            , viewFormList personForm "favoriteFoods" "Favorite Foods"
            , button [ type_ "submit" ] [ text "Submit" ]
            ]
        ]


colorOptions : List ( String, String )
colorOptions =
    [ ( "", "- select color -" )
    , ( "Red", "Red" )
    , ( "Yellow", "Yellow" )
    , ( "Green", "Green" )
    , ( "Blue", "Blue" )
    , ( "Purple", "Purple" )
    ]


viewSelectInput : List ( String, String ) -> Form CustomFormError Person -> String -> String -> Html Form.Msg
viewSelectInput options =
    viewInput (Input.selectInput options)


viewTextInput : Form CustomFormError Person -> String -> String -> Html Form.Msg
viewTextInput =
    viewInput Input.textInput


viewInput : Input.Input CustomFormError String -> Form CustomFormError Person -> String -> String -> Html Form.Msg
viewInput inputFn personForm fieldName fieldLabel =
    let
        field =
            Form.getFieldAsString fieldName personForm

        errorText =
            case field.liveError of
                Just error ->
                    div [ style "color" "red" ]
                        [ text <| errorToString error ]

                _ ->
                    text ""
    in
    div [ style "margin-bottom" "1rem" ]
        [ div [] [ label [] [ text fieldLabel ] ]
        , div []
            [ inputFn field []
            , errorText
            ]
        ]


viewFormList : Form CustomFormError Person -> String -> String -> Html Form.Msg
viewFormList personForm fieldName fieldLabel =
    let
        itemViews =
            List.map (viewItem personForm fieldName) (Form.getListIndexes fieldName personForm)
    in
    div [ style "margin-bottom" "1rem" ]
        [ div [] [ label [] [ text fieldLabel ] ]
        , ul [] itemViews
        , a
            [ style "color" "blue"
            , style "cursor" "pointer"
            , onClick (Form.Append fieldName)
            ]
            [ text "Add" ]
        ]


viewItem : Form CustomFormError Person -> String -> Int -> Html Form.Msg
viewItem personForm name i =
    li [ style "display" "flex" ]
        [ viewTextInput personForm (name ++ "." ++ String.fromInt i) ""
        , a
            [ style "color" "red"
            , style "margin-left" "1rem"
            , style "cursor" "pointer"
            , onClick (Form.RemoveItem name i)
            ]
            [ text "Remove" ]
        ]


errorToString : ErrorValue CustomFormError -> String
errorToString error =
    case error of
        Empty ->
            "Field cannot be empty"

        InvalidString ->
            "Field cannot be empty"

        InvalidInt ->
            "This is not a valid number"

        CustomError err ->
            case err of
                InvalidColor ->
                    "Invalid color"

        _ ->
            "Invalid value"
