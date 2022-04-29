module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
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
    { todoList : TodoList
    , newTodo : String
    }


type TodoList
    = Loading
    | Error String
    | Success (List TodoItem)


type alias TodoItem =
    { id : Int
    , name : String
    , completed : Bool
    }


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"


getTodos : Cmd Msg
getTodos =
    Http.get
        { url = baseApiUrl ++ "todos"
        , expect = Http.expectJson GotTodos decodeTodoList
        }


postTodo : String -> Cmd Msg
postTodo label =
    let
        body =
            Encode.object [ ( "label", Encode.string label ) ]
    in
    Http.post
        { url = baseApiUrl ++ "todos"
        , body = Http.jsonBody body
        , expect = Http.expectWhatever SaveTodoResponse
        }


putTodo : TodoItem -> Cmd Msg
putTodo todoItem =
    let
        body =
            Encode.object
                [ ( "label", Encode.string todoItem.name )
                , ( "completed", Encode.bool <| not todoItem.completed )
                ]
    in
    Http.request
        { method = "PUT"
        , headers = []
        , url = baseApiUrl ++ "todos/" ++ String.fromInt todoItem.id
        , body = Http.jsonBody body
        , expect = Http.expectWhatever <| CompletedTodoItemResponse todoItem
        , timeout = Nothing
        , tracker = Nothing
        }


decodeTodoList : Decode.Decoder (List TodoItem)
decodeTodoList =
    Decode.list decodeTodoItem



-- decodeTodoItem : Decode.Decoder TodoItem
-- decodeTodoItem =
--     Decode.map3 TodoItem
--         (Decode.field "id" Decode.int)
--         (Decode.field "label" Decode.string)
--         (Decode.field "completed" Decode.bool)


decodeTodoItem : Decode.Decoder TodoItem
decodeTodoItem =
    Decode.succeed TodoItem
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "label" Decode.string
        |> Pipeline.required "completed" Decode.bool


init : () -> ( Model, Cmd Msg )
init _ =
    ( { todoList = Loading
      , newTodo = ""
      }
    , getTodos
    )


type Msg
    = GotTodos (Result Http.Error (List TodoItem))
    | InsertedNewTodo String
    | ClickedAddTodo
    | SaveTodoResponse (Result Http.Error ())
    | CompletedTodo TodoItem
    | CompletedTodoItemResponse TodoItem (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTodos result ->
            case result of
                Ok todos ->
                    ( { model | todoList = Success todos }, Cmd.none )

                Err _ ->
                    ( { model | todoList = Error "Unable to get TODOs" }, Cmd.none )

        InsertedNewTodo todo ->
            ( { model | newTodo = todo }, Cmd.none )

        ClickedAddTodo ->
            ( model, postTodo model.newTodo )

        SaveTodoResponse result ->
            case result of
                Ok _ ->
                    ( model, getTodos )

                Err _ ->
                    ( { model | todoList = Error "Unable to save TODOs" }, Cmd.none )

        CompletedTodo todoItem ->
            -- let
            --     updatedTodoList =
            --         case model.todoList of
            --             Loading ->
            --                 model.todoList
            --             Error _ ->
            --                 model.todoList
            --             Success todos ->
            --                 todos
            --                     |> List.map
            --                         (\todo ->
            --                             if todo.id == todoItem.id then
            --                                 { todo | completed = not todoItem.completed }
            --                             else
            --                                 todo
            --                         )
            --                     |> Success
            -- in
            -- ( { model | todoList = updatedTodoList }, putTodo todoItem )
            ( model, putTodo todoItem )

        CompletedTodoItemResponse todoItem result ->
            let
                updatedTodoList =
                    case model.todoList of
                        Loading ->
                            model.todoList

                        Error _ ->
                            model.todoList

                        Success todos ->
                            todos
                                |> List.map
                                    (\todo ->
                                        if todo.id == todoItem.id then
                                            { todo | completed = not todoItem.completed }

                                        else
                                            todo
                                    )
                                |> Success
            in
            case result of
                Ok _ ->
                    ( { model | todoList = updatedTodoList }, Cmd.none )

                Err _ ->
                    ( { model | todoList = Error "Unable to update todo" }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div Styles.containerStyle
        [ Html.h1 [] [ Html.text "Todo list" ]
        , todoForm model
        , todoListView model.todoList
        ]


todoListView : TodoList -> Html Msg
todoListView todoList =
    case todoList of
        Loading ->
            Html.div [] [ Html.text "Loading..." ]

        Error error ->
            Html.div Styles.todoListErrorStyle [ Html.text error ]

        Success todos ->
            Html.ul Styles.todoListListStyle <| List.map todoView todos


todoView : TodoItem -> Html Msg
todoView todoItem =
    let
        checkText =
            if todoItem.completed then
                "✓"

            else
                ""
    in
    Html.li Styles.todoStyle
        [ Html.a (Styles.todoCheckStyle ++ [ Events.onClick <| CompletedTodo todoItem ]) [ Html.text checkText ]
        , Html.text todoItem.name
        ]


todoForm : Model -> Html Msg
todoForm model =
    Html.div Styles.formStyle
        [ Html.input (Styles.formInputStyle ++ [ Attributes.type_ "text", Attributes.value model.newTodo, Events.onInput InsertedNewTodo ]) []
        , Html.button (Styles.formButtonStyle ++ [ Events.onClick ClickedAddTodo ]) [ Html.text "Add" ]
        ]
