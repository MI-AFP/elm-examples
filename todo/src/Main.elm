module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Encode as Encode
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
    { todos : TodoList
    , newLabel : String
    }


type TodoList
    = Loading
    | Error String
    | Success (List Todo)


type alias Todo =
    { id : Int
    , label : String
    , completed : Bool
    }


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"


todoDecoder : Decode.Decoder Todo
todoDecoder =
    Decode.map3 Todo
        (Decode.field "id" Decode.int)
        (Decode.field "label" Decode.string)
        (Decode.field "completed" Decode.bool)


todoListDecoder : Decode.Decoder (List Todo)
todoListDecoder =
    Decode.list todoDecoder


getTodos : Cmd Msg
getTodos =
    Http.get
        { url = baseApiUrl ++ "todos"
        , expect = Http.expectJson GotTodos todoListDecoder
        }


postTodo : String -> Cmd Msg
postTodo todoLabel =
    let
        body =
            Encode.object
                [ ( "label", Encode.string todoLabel ) ]
    in
    Http.post
        { url = baseApiUrl ++ "todos"
        , body = Http.jsonBody body
        , expect = Http.expectWhatever SaveTodoResponse
        }


putTodo : Todo -> Cmd Msg
putTodo todo =
    let
        body =
            Encode.object
                [ ( "label", Encode.string todo.label )
                , ( "completed", Encode.bool todo.completed )
                ]
    in
    Http.request
        { method = "PUT"
        , headers = []
        , url = baseApiUrl ++ "todos/" ++ String.fromInt todo.id
        , body = Http.jsonBody body
        , expect = Http.expectWhatever SaveTodoResponse
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
    = InsertedLabel String
    | GotTodos (Result Http.Error (List Todo))
    | ClickedSaveTodo
    | SaveTodoResponse (Result Http.Error ())
    | ToggledCompleted Todo


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InsertedLabel label ->
            ( { model | newLabel = label }, Cmd.none )

        GotTodos result ->
            let
                newTodos =
                    case result of
                        Ok todos ->
                            Success todos

                        Err _ ->
                            Error "Unable to get TODOs"
            in
            ( { model | todos = newTodos }, Cmd.none )

        ClickedSaveTodo ->
            if String.length model.newLabel > 0 then
                ( { model | newLabel = "" }, postTodo model.newLabel )

            else
                ( model, Cmd.none )

        SaveTodoResponse _ ->
            ( model, getTodos )

        ToggledCompleted todo ->
            ( model, putTodo { todo | completed = not todo.completed } )


view : Model -> Html Msg
view model =
    Html.div Styles.containerStyle
        [ Html.h1 [] [ Html.text "Todo list" ]
        , todoFormView model
        , todoListView model
        ]


todoFormView : Model -> Html Msg
todoFormView model =
    Html.div Styles.formStyle
        [ Html.input
            (Styles.formInputStyle
                ++ [ Attributes.type_ "text"
                   , Attributes.value model.newLabel
                   , Events.onInput InsertedLabel
                   ]
            )
            []
        , Html.button (Styles.formButtonStyle ++ [ Events.onClick ClickedSaveTodo ])
            [ Html.text "Add" ]
        ]


todoListView : Model -> Html Msg
todoListView model =
    case model.todos of
        Success todos ->
            todoListListView todos

        Loading ->
            todoListLoadingView

        Error error ->
            todoListErrorView error


todoListListView : List Todo -> Html Msg
todoListListView todos =
    Html.ul Styles.todoListListStyle
        (List.map todoView todos)


todoListLoadingView : Html Msg
todoListLoadingView =
    Html.div [] [ Html.text "Loading..." ]


todoListErrorView : String -> Html Msg
todoListErrorView error =
    Html.div Styles.todoListErrorStyle [ Html.text error ]


todoView : Todo -> Html Msg
todoView todo =
    let
        checkText =
            if todo.completed then
                "✓"

            else
                ""
    in
    Html.li Styles.todoStyle
        [ Html.a (Styles.todoCheckStyle ++ [ Events.onClick <| ToggledCompleted todo ])
            [ Html.text checkText ]
        , Html.text todo.label
        ]
