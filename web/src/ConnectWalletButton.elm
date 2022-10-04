module ConnectWalletButton exposing (viewConnectWalletButton)

import ColorSchemes
import Element exposing (..)
import Element.Region as Region
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input

viewConnectWalletButton : Element msg
viewConnectWalletButton =
    Input.button
        [
        ]
        { onPress = Nothing
        , label = text "ウォレットに接続"
        }
