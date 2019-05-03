module Todos exposing (main)

import Browser
import Html exposing (Html, a, button, div, h1, input, li, text, ul)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Styles.Todos as Styles


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { todos : TodoList
    , newLabel : String
    }


type TodoList
    = Loading
    | Error String
    | TodoList (List Todo)


type alias Todo =
    { id : Int
    , label : String
    , completed : Bool
    }


todoDecoder : Decoder Todo
todoDecoder =
    D.map3 Todo
        (D.field "id" D.int)
        (D.field "label" D.string)
        (D.field "completed" D.bool)


todoListDecoder : Decoder (List Todo)
todoListDecoder =
    D.list todoDecoder


getTodos : Cmd Msg
getTodos =
    Http.get
        { url = "http://localhost:3000/todos"
        , expect = Http.expectJson GotTodos todoListDecoder
        }


postTodo : String -> Cmd Msg
postTodo todoLabel =
    let
        body =
            E.object
                [ ( "label", E.string todoLabel ) ]
    in
    Http.post
        { url = "http://localhost:3000/todos"
        , body = Http.jsonBody body
        , expect = Http.expectWhatever SavedTodo
        }


putTodo : Todo -> Cmd Msg
putTodo todo =
    let
        body =
            E.object
                [ ( "label", E.string todo.label )
                , ( "completed", E.bool todo.completed )
                ]
    in
    Http.request
        { method = "PUT"
        , headers = []
        , url = "http://localhost:3000/todos/" ++ String.fromInt todo.id
        , body = Http.jsonBody body
        , expect = Http.expectWhatever SavedTodo
        , timeout = Nothing
        , tracker = Nothing
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { todos = Loading
      , newLabel = ""
      }
    , getTodos
    )


type Msg
    = ChangeNewLabel String
    | GotTodos (Result Http.Error (List Todo))
    | SaveTodo
    | SavedTodo (Result Http.Error ())
    | ToggleCompleted Todo


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeNewLabel value ->
            ( { model | newLabel = value }, Cmd.none )

        GotTodos result ->
            let
                newTodos =
                    case result of
                        Ok todos ->
                            TodoList todos

                        Err _ ->
                            Error "Unable to get TODOs"
            in
            ( { model | todos = newTodos }, Cmd.none )

        SaveTodo ->
            if String.length model.newLabel > 0 then
                ( { model | newLabel = "" }, postTodo model.newLabel )

            else
                ( model, Cmd.none )

        SavedTodo _ ->
            ( model, getTodos )

        ToggleCompleted todo ->
            ( model, putTodo { todo | completed = not todo.completed } )


view : Model -> Html Msg
view model =
    div Styles.containerStyle
        [ h1 [] [ text "Todo list" ]
        , todoFormView model
        , todoListView model
        ]


todoFormView : Model -> Html Msg
todoFormView model =
    div Styles.formStyle
        [ input (Styles.formInputStyle ++ [ type_ "text", value model.newLabel, onInput ChangeNewLabel ]) []
        , button (Styles.formButtonStyle ++ [ onClick SaveTodo ]) [ text "Add" ]
        ]


todoListView : Model -> Html Msg
todoListView model =
    case model.todos of
        TodoList todos ->
            todoListListView todos

        Loading ->
            todoListLoadingView

        Error error ->
            todoListErrorView error


todoListListView : List Todo -> Html Msg
todoListListView todos =
    ul Styles.todoListListStyle
        (List.map todoView todos)


todoListLoadingView : Html Msg
todoListLoadingView =
    div [] [ text "Loading..." ]


todoListErrorView : String -> Html Msg
todoListErrorView error =
    div Styles.todoListErrorStyle [ text error ]


todoView : Todo -> Html Msg
todoView todo =
    let
        checkText =
            if todo.completed then
                "✓"

            else
                ""
    in
    li Styles.todoStyle
        [ a (Styles.todoCheckStyle ++ [ onClick <| ToggleCompleted todo ]) [ text checkText ]
        , text todo.label
        ]
