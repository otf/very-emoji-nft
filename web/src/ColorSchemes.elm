module ColorSchemes exposing (..)

import Element exposing (rgb255)
import Element.Background exposing (color, gradient)
import Element.Border as Border
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

galleryBackgroundColor =
    color <| rgb255 250 250 250

galleryBorderColor =
    Border.color <| rgb255 237 210 233


emojiForegroundColor =
    Font.color <| rgb255 115 115 115


emojiBackgroundColor =
    color <| rgb255 230 230 230


emojiBorderColor =
    Border.color <| rgb255 237 210 233


mintButtonForegroundColor =
    Font.color <| rgb255 255 255 255


mintButtonBorderColor =
    Border.color <| rgb255 255 185 200


mintButtonBackgroundColor =
    color <| rgb255 255 185 220

