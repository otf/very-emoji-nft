module Components.Emoji exposing (viewEmoji)

import BigInt exposing (BigInt, toString)
import ColorSchemes
import Components.MintButton exposing (viewMintButton)
import Config
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Eth.Types exposing (Address)


viewIpfsImage : BigInt -> Element msg
viewIpfsImage tokenId =
    image
        [ width fill
        , height fill
        ]
        { src = Config.imageUrl tokenId
        , description = "Very Emoji No." ++ (toString tokenId)
        }

viewTokenId : BigInt -> Element msg
viewTokenId tokenId =
    el
      [ Region.heading 3
      , paddingXY 0 8
      , Font.size 20
      , Font.bold
      ]
      <|
          text ("Very Emoji " ++ "#" ++ (toString tokenId))

viewEmoji : (BigInt -> msg) -> Maybe Address -> (BigInt -> Bool) -> BigInt -> Element msg
viewEmoji msg walletAddress isMinted tokenId =
    el
        [ Border.width 2
        , Border.rounded 16
        , ColorSchemes.emojiBackgroundColor
        , ColorSchemes.emojiBorderColor
        , ColorSchemes.emojiForegroundColor
        , width (fill |> minimum 198)
        ]
        <|
            column
                [ width fill
                , spacing 16
                , padding 16
                ]
                [ viewTokenId tokenId
                , viewIpfsImage tokenId
                , viewMintButton (msg tokenId) walletAddress (isMinted tokenId)
                ]
