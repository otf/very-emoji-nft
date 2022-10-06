module Components.MintButton exposing (viewMintButton)

import ColorSchemes
import Element exposing (..)
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Eth.Types exposing (Address)
import Eth.Utils exposing (addressToString)


viewMintButton : msg -> Bool -> Element msg
viewMintButton msg isMinted =
    Input.button
        [ padding 12
        , width fill
        , ColorSchemes.mintButtonBackgroundColor
        , Font.center
        , Font.size 16
        , Font.bold
        , ColorSchemes.mintButtonForegroundColor
        , Border.width 2
        , Border.rounded 20
        , ColorSchemes.mintButtonBorderColor
        , alpha (if isMinted then 0.5 else 1.0)
        ]
        { onPress = if isMinted then Nothing else Just msg
        , label = text "ミント"
        }
