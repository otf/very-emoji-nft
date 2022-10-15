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
                    "ウォレットを接続"
    in
    Input.button
        [ padding 12
        , width fill
        , Font.center
        , Font.size 16
        , Font.bold
        , Font.family
            [ Font.external
                { name = "DotGothic16"
                , url = "https://fonts.googleapis.com/css2?family=DotGothic16"
                }
            , Font.sansSerif
            ]
        , Border.width 2
        , Border.rounded 8
        , Border.color <| rgb255 166 43 113
        , ColorSchemes.buttonForegroundColor
        , ColorSchemes.buttonBackgroundColor
        , Border.shadow
            { offset = (0.0, 4.0)
            , size = 0.0
            , blur = 0.0
            , color = rgb255 166 43 113
            }
        , focused
            [
            ]
        ]
        { onPress = Just msg
        , label = text buttonText
        }
