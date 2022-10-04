module ConnectWalletButton exposing (viewConnectWalletButton)

import ColorSchemes
import Element exposing (..)
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region


viewConnectWalletButton : Element msg
viewConnectWalletButton =
    Input.button
        [ padding 12
        , width fill
        , Font.center
        , Font.size 16
        , Font.bold
        , Border.width 2
        , Border.rounded 20
        , ColorSchemes.buttonForegroundColor
        , ColorSchemes.buttonBackgroundColor
        ]
        { onPress = Nothing
        , label = text "ウォレットに接続"
        }
