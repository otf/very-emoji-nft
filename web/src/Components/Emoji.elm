module Components.Emoji exposing (viewEmoji)

import ColorSchemes
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region


viewEmoji : Element msg
viewEmoji =
    el
        [ width (px 300)
        , height (px 300)
        , Border.width 2
        , Border.rounded 16
        , ColorSchemes.emojiBackgroundColor
        , ColorSchemes.emojiBorderColor
        ]
        Element.none
