module Components.ConnectWalletButton exposing (viewConnectWalletButton)

import ColorSchemes
import Element exposing (..)
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Eth.Types exposing (Address)
import Eth.Utils exposing (addressToString)


viewConnectWalletButton : Maybe Address -> msg -> Element msg
viewConnectWalletButton walletAddress msg =
    let
        buttonText =
            case walletAddress of
                Just walletAddr ->
                    let
                        strAddr =
                            addressToString walletAddr
                    in
                    (String.left 6 strAddr) ++ "..." ++ (String.right 4 strAddr)
                Nothing ->
                    "ウォレットに接続"
    in
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
        { onPress = Just msg
        , label = text buttonText
        }
