module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as BrowserNavigation
import Home
import Html
import Login
import Url
import Url.Parser as UrlParser


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }


type alias Flags =
    Maybe String


type alias Model =
    { key : BrowserNavigation.Key
    , route : Route
    , token : Maybe String
    , loginModel : Login.Model
    , homeModel : Home.Model
    }


type Route
    = Home
    | Login
    | NotFound


routeParser : UrlParser.Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Home UrlParser.top
        , UrlParser.map Login (UrlParser.s "login")
        ]


toRoute : Url.Url -> Route
toRoute url =
    Maybe.withDefault NotFound (UrlParser.parse routeParser url)


type Msg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | LoginMsg Login.Msg
    | HomeMsg Home.Msg


init : Flags -> Url.Url -> BrowserNavigation.Key -> ( Model, Cmd Msg )
init token url key =
    let
        route =
            toRoute url

        redirectCmd =
            case ( route, token ) of
                ( Home, Nothing ) ->
                    BrowserNavigation.pushUrl key "/login"

                ( Login, Just _ ) ->
                    BrowserNavigation.pushUrl key "/"

                _ ->
                    Cmd.none
    in
    ( { key = key
      , route = route
      , token = token
      , loginModel = Login.init
      , homeModel = Home.init
      }
    , redirectCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , BrowserNavigation.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , BrowserNavigation.load href
                    )

        ChangedUrl url ->
            ( { model | route = toRoute url }
            , Cmd.none
            )

        LoginMsg loginMsg ->
            let
                ( updatedLoginModel, loginCmd ) =
                    Login.update model.key
                        LoginMsg
                        loginMsg
                        model.loginModel
            in
            ( { model | loginModel = updatedLoginModel }
            , loginCmd
            )

        HomeMsg homeMsg ->
            ( { model | homeModel = Home.update homeMsg model.homeModel }
            , Cmd.none
            )


view : Model -> Document Msg
view model =
    let
        content =
            case model.route of
                Login ->
                    Login.view model.loginModel
                        |> Html.map LoginMsg

                Home ->
                    Home.view model.homeModel
                        |> Html.map HomeMsg

                NotFound ->
                    Html.h1 [] [ Html.text "Not Found" ]
    in
    { title = "Elm Webpack Boilerplate"
    , body = [ content ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
