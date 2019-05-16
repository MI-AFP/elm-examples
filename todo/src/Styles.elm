module Styles exposing
    ( containerStyle
    , formButtonStyle
    , formInputStyle
    , formStyle
    , todoCheckStyle
    , todoListErrorStyle
    , todoListListStyle
    , todoStyle
    )

import Html.Attributes exposing (style)


containerStyle =
    [ style "width" "30rem"
    , style "margin" "auto"
    , style "font-family" "sans-serif"
    , style "color" "#0D0D0D"
    ]


formStyle =
    [ style "display" "flex"
    , style "margin-bottom" "1rem"
    ]


formInputStyle =
    [ style "flex-grow" "1"
    , style "font-size" "1rem"
    , style "padding" ".75rem"
    , style "border-radius" ".5rem 0 0 .5rem"
    , style "border" "1px solid #D8D9D7"
    , style "outline" "none"
    ]


formButtonStyle =
    [ style "background" "#70898C"
    , style "color" "#fff"
    , style "border" "none"
    , style "border-radius" "0 .5rem .5rem 0"
    , style "font-size" "1rem"
    , style "cursor" "pointer"
    , style "width" "5rem"
    , style "outline" "none"
    ]


todoListListStyle =
    [ style "padding" "0"
    , style "margin" "0"
    ]


todoListErrorStyle =
    [ style "padding" ".75rem"
    , style "color" "#900"
    , style "background" "#fee"
    , style "border-radius" ".5rem"
    ]


todoStyle =
    [ style "list-style-type" "none"
    , style "display" "flex"
    , style "margin-bottom" ".5rem"
    , style "background" "#D8D9D7"
    , style "padding" ".75rem"
    , style "border-radius" ".5rem"
    ]


todoCheckStyle =
    [ style "width" "1rem"
    , style "height" "1rem"
    , style "border" "1px solid #0D0D0D"
    , style "border-radius" "50%"
    , style "margin-right" ".5rem"
    , style "text-align" "center"
    , style "cursor" "pointer"
    ]
