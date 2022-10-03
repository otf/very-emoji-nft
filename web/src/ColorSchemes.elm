module ColorSchemes exposing (..)

import Element exposing (rgb255)
import Element.Background exposing (gradient)


backgroundColor =
    gradient
        { angle = 0
        , steps =
            [ rgb255 199 201 248
            , rgb255 230 234 255
            , rgb255 255 186 219
            ]
        }
