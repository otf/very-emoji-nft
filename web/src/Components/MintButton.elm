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


viewMintButton : msg -> Maybe Address -> Bool -> Bool -> Element msg
viewMintButton msg walletAddress isMinted isLoading =
    let
        canMint =
            walletAddress /= Nothing && not isMinted
    in
    Input.button
        [ padding 12
        , width fill
        , ColorSchemes.mintButtonBackgroundColor
        , Font.center
        , Font.size 24
        , Font.bold
        , ColorSchemes.mintButtonForegroundColor
        , Border.width 2
        , Border.rounded 24
        , ColorSchemes.mintButtonBorderColor
        , alpha (if canMint then 1.0 else 0.5)
        ]
        { onPress = if canMint && not isLoading then Just msg else Nothing
        , label =
            if isLoading then
                image [] { src = "images/rolling.gif", description = "minting..." }
            else
                text "ミント"
        }
