module Main exposing (Msg(..), main, update, view)

import Browser
import Html as H
import Html.Attributes as HA
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    { time : Time.Posix }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { time = Time.millisToPosix 0 }
    , Cmd.none
    )


type Msg
    = NewTime Time.Posix


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 NewTime


update msg model =
    case msg of
        NewTime time ->
            ( { model | time = time }, Cmd.none )


view model =
    H.div [ HA.style "text-align" "center" ]
        [ clock model.time
        ]


clock : Time.Posix -> Svg msg
clock time =
    let
        seconds =
            toFloat (Time.toSecond Time.utc time) / 60

        minutes =
            toFloat (Time.toMinute Time.utc time) / 60

        hours =
            toFloat (modBy 12 (Time.toHour Time.utc time)) / 12
    in
    svg [ width "200", height "200" ]
        ([ circle
            [ cx "100"
            , cy "100"
            , r "100"
            , fill "#ddd"
            ]
            []
         ]
            ++ hoursTicks
            ++ [ hourHand hours
               , minutesHand minutes
               , secondHand seconds
               ]
        )


hoursTicks : List (Svg msg)
hoursTicks =
    List.map hour <| List.range 0 11


hour : Int -> Svg msg
hour tick =
    let
        angle =
            toFloat tick / 12

        length1 =
            if modBy 3 tick == 0 then
                75

            else
                85

        length2 =
            100

        c =
            100

        x1_ =
            c + length1 * cos ((angle - 0.25) * 2 * pi)

        y1_ =
            c + length1 * sin ((angle - 0.25) * 2 * pi)

        x2_ =
            c + length2 * cos ((angle - 0.25) * 2 * pi)

        y2_ =
            c + length2 * sin ((angle - 0.25) * 2 * pi)
    in
    line
        [ x1 <| String.fromFloat x1_
        , y1 <| String.fromFloat y1_
        , x2 <| String.fromFloat x2_
        , y2 <| String.fromFloat y2_
        , stroke "#ccc"
        , strokeWidth "5"
        ]
        []


hourHand =
    hand [ stroke "black", strokeWidth "4" ] 75


minutesHand =
    hand [ stroke "black", strokeWidth "3" ] 85


secondHand =
    hand [ stroke "red", strokeWidth "1" ] 95


hand : List (Attribute msg) -> Float -> Float -> Svg msg
hand attributes length angle =
    let
        c =
            100

        x =
            c + length * cos ((angle - 0.25) * 2 * pi)

        y =
            c + length * sin ((angle - 0.25) * 2 * pi)
    in
    line
        ([ x1 "100"
         , y1 "100"
         , x2 <| String.fromFloat x
         , y2 <| String.fromFloat y
         ]
            ++ attributes
        )
        []
