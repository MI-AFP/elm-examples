module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attributes
import Svg
import Svg.Attributes as SvgAttributes
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
    = GotNewTime Time.Posix


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 GotNewTime


update msg model =
    case msg of
        GotNewTime time ->
            ( { model | time = time }, Cmd.none )


view model =
    Html.div [ Attributes.style "text-align" "center" ]
        [ clock model.time
        ]


clock : Time.Posix -> Svg.Svg msg
clock time =
    let
        seconds =
            toFloat (Time.toSecond Time.utc time) / 60

        minutes =
            toFloat (Time.toMinute Time.utc time) / 60

        hours =
            toFloat (modBy 12 (Time.toHour Time.utc time)) / 12
    in
    Svg.svg [ SvgAttributes.width "200", SvgAttributes.height "200" ]
        ([ Svg.circle
            [ SvgAttributes.cx "100"
            , SvgAttributes.cy "100"
            , SvgAttributes.r "100"
            , SvgAttributes.fill "#ddd"
            ]
            []
         ]
            ++ hoursTicks
            ++ [ hourHand hours
               , minutesHand minutes
               , secondHand seconds
               ]
        )


hoursTicks : List (Svg.Svg msg)
hoursTicks =
    List.map hour <| List.range 0 11


hour : Int -> Svg.Svg msg
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
    Svg.line
        [ SvgAttributes.x1 <| String.fromFloat x1_
        , SvgAttributes.y1 <| String.fromFloat y1_
        , SvgAttributes.x2 <| String.fromFloat x2_
        , SvgAttributes.y2 <| String.fromFloat y2_
        , SvgAttributes.stroke "#ccc"
        , SvgAttributes.strokeWidth "5"
        ]
        []


hourHand : Float -> Svg.Svg msg
hourHand =
    hand
        [ SvgAttributes.stroke "black"
        , SvgAttributes.strokeWidth "4"
        ]
        75


minutesHand : Float -> Svg.Svg msg
minutesHand =
    hand
        [ SvgAttributes.stroke "black"
        , SvgAttributes.strokeWidth "3"
        ]
        85


secondHand : Float -> Svg.Svg msg
secondHand =
    hand
        [ SvgAttributes.stroke "red"
        , SvgAttributes.strokeWidth "1"
        ]
        95


hand : List (Svg.Attribute msg) -> Float -> Float -> Svg.Svg msg
hand attributes length angle =
    let
        c =
            100

        x =
            c + length * cos ((angle - 0.25) * 2 * pi)

        y =
            c + length * sin ((angle - 0.25) * 2 * pi)
    in
    Svg.line
        ([ SvgAttributes.x1 "100"
         , SvgAttributes.y1 "100"
         , SvgAttributes.x2 <| String.fromFloat x
         , SvgAttributes.y2 <| String.fromFloat y
         ]
            ++ attributes
        )
        []
