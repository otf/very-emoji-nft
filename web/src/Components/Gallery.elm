module Components.Gallery exposing (viewGallery)

import ColorSchemes
import Element exposing (..)
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region


viewGallery : (List (Element msg)) -> (Element msg -> Element msg) -> Element msg
viewGallery emojiList wrapContainer =
    el
        [ width fill
        ]
        <|
            wrapContainer
                <|
                    wrappedRow
                        [ width fill
                        , spacing 24
                        ]
                        emojiList
