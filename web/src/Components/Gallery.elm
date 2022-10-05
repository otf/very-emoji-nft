module Components.Gallery exposing (viewGallery)

import ColorSchemes
import Element exposing (..)
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region


viewGallery : (Element msg -> Element msg) -> Element msg
viewGallery wrapContainer =
    el
        [ width fill
        ]
        <|
            wrapContainer
                <|
                    el 
                        [ width fill
                        , height (px 1920)
                        , ColorSchemes.galleryBackgroundColor
                        , Border.width 2
                        , Border.rounded 16
                        , ColorSchemes.galleryBorderColor
                        ] Element.none
