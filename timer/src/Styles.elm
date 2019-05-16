module Styles exposing
    ( buttonStyle
    , containerStyle
    , timeStyle
    )

import Html.Attributes exposing (style)


containerStyle =
    [ style "font-family" "sans-serif"
    , style "text-align" "center"
    ]


timeStyle =
    [ style "font-size" "10rem" ]


buttonStyle =
    [ style "font-size" "1.5rem"
    , style "margin" ".25rem"
    , style "padding" ".25rem 1rem"
    ]
