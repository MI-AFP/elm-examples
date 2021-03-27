module Main exposing (main)

import Browser exposing (Document)
import Form
import Form.Error as FormError
import Form.Input as FormInput
import Form.Validate as FormValidate
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type alias Model =
    { personForm : Form.Form CustomFormError Person
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


initPersonForm : Form.Form CustomFormError Person
initPersonForm =
    Form.initial [] personValidation


personValidation : FormValidate.Validation CustomFormError Person
personValidation =
    FormValidate.map4 Person
        (FormValidate.field "name" FormValidate.string)
        (FormValidate.field "age" FormValidate.int)
        (FormValidate.field "favoriteColor" colorValidation)
        (FormValidate.field "favoriteFoods" (FormValidate.list FormValidate.string))


colorValidation : FormValidate.Validation CustomFormError Color
colorValidation =
    FormValidate.string
        |> FormValidate.andThen
            (\value ->
                case value of
                    "Red" ->
                        FormValidate.succeed Red

                    "Yellow" ->
                        FormValidate.succeed Yellow

                    "Green" ->
                        FormValidate.succeed Green

                    "Blue" ->
                        FormValidate.succeed Blue

                    "Purple" ->
                        FormValidate.succeed Purple

                    _ ->
                        FormValidate.fail <| FormValidate.customError InvalidColor
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


viewForm : Form.Form CustomFormError Person -> Html Form.Msg
viewForm personForm =
    Html.form [ Events.onSubmit Form.Submit ]
        [ Html.fieldset []
            [ Html.legend [] [ Html.text "Person" ]
            , viewTextInput personForm "name" "Name"
            , viewTextInput personForm "age" "Age"
            , viewSelectInput colorOptions personForm "favoriteColor" "Favorite Color"
            , viewFormList personForm "favoriteFoods" "Favorite Foods"
            , Html.button [ Attributes.type_ "submit" ]
                [ Html.text "Submit" ]
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


viewSelectInput : List ( String, String ) -> Form.Form CustomFormError Person -> String -> String -> Html Form.Msg
viewSelectInput options =
    viewInput (FormInput.selectInput options)


viewTextInput : Form.Form CustomFormError Person -> String -> String -> Html Form.Msg
viewTextInput =
    viewInput FormInput.textInput


viewInput : FormInput.Input CustomFormError String -> Form.Form CustomFormError Person -> String -> String -> Html Form.Msg
viewInput inputFn personForm fieldName fieldLabel =
    let
        field =
            Form.getFieldAsString fieldName personForm

        errorText =
            case field.liveError of
                Just error ->
                    Html.div [ Attributes.style "color" "red" ]
                        [ Html.text <| errorToString error ]

                _ ->
                    Html.text ""
    in
    Html.div [ Attributes.style "margin-bottom" "1rem" ]
        [ Html.div [] [ Html.label [] [ Html.text fieldLabel ] ]
        , Html.div []
            [ inputFn field []
            , errorText
            ]
        ]


viewFormList : Form.Form CustomFormError Person -> String -> String -> Html Form.Msg
viewFormList personForm fieldName fieldLabel =
    let
        itemViews =
            personForm
                |> Form.getListIndexes fieldName
                |> List.map (viewItem personForm fieldName)
    in
    Html.div [ Attributes.style "margin-bottom" "1rem" ]
        [ Html.div [] [ Html.label [] [ Html.text fieldLabel ] ]
        , Html.ul [] itemViews
        , Html.a
            [ Attributes.style "color" "blue"
            , Attributes.style "cursor" "pointer"
            , Events.onClick <| Form.Append fieldName
            ]
            [ Html.text "Add" ]
        ]


viewItem : Form.Form CustomFormError Person -> String -> Int -> Html Form.Msg
viewItem personForm name i =
    Html.li [ Attributes.style "display" "flex" ]
        [ viewTextInput personForm (name ++ "." ++ String.fromInt i) ""
        , Html.a
            [ Attributes.style "color" "red"
            , Attributes.style "margin-left" "1rem"
            , Attributes.style "cursor" "pointer"
            , Events.onClick (Form.RemoveItem name i)
            ]
            [ Html.text "Remove" ]
        ]


errorToString : FormError.ErrorValue CustomFormError -> String
errorToString error =
    case error of
        FormError.Empty ->
            "Field cannot be empty"

        FormError.InvalidString ->
            "Field cannot be empty"

        FormError.InvalidInt ->
            "This is not a valid number"

        FormError.CustomError err ->
            case err of
                InvalidColor ->
                    "Invalid color"

        -- Bad practice to use default for custom type values in case - of expression
        _ ->
            "Invalid value"
