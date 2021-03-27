module Requests exposing (fetchToken)

import Http
import Json.Decode as Decode
import Json.Encode as Encode


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"


fetchToken : { r | username : String, password : String } -> (Result Http.Error String -> msg) -> Cmd msg
fetchToken { username, password } msg =
    let
        body =
            Encode.object
                [ ( "username", Encode.string username )
                , ( "password", Encode.string password )
                ]
    in
    Http.post
        { url = baseApiUrl ++ "users/token"
        , body = Http.jsonBody body
        , expect = Http.expectJson msg (Decode.field "token" Decode.string)
        }
