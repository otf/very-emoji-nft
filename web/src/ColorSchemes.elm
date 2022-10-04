module ColorSchemes exposing (..)

import Element exposing (rgb255)
import Element.Background exposing (color, gradient)
import Element.Font as Font


backgroundColor =
    gradient
        { angle = 0
        , steps =
            [ rgb255 230 234 255
            , rgb255 255 186 219
            , rgb255 199 201 248
            ]
        }


buttonForegroundColor =
    Font.color <| rgb255 70 85 150


buttonBackgroundColor =
    color <| rgb255 206 213 244


jumbotronBackgroundColor =
    color <| rgb255 200 150 200


jumbotronForegroundColor =
    Font.color <| rgb255 60 60 60
