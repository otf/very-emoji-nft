module Components.Emoji exposing (viewEmoji)

import BigInt exposing (BigInt, toString)
import ColorSchemes
import Components.MintButton exposing (viewMintButton)
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region

imageUrl : BigInt -> String
imageUrl tokenId =
    "http://localhost:8080/ipfs/QmU8iCM7QYECrWtWjKUN6QZcu6Z4Se9gM1CjDtsUAVc4AX/1.svg"

viewIpfsImage : BigInt -> Element msg
viewIpfsImage tokenId =
    image
        [ width fill
        , height fill
        ]
        { src = imageUrl tokenId
        , description = "Very Emoji No." ++ (toString tokenId)
        }

viewTokenId : BigInt -> Element msg
viewTokenId tokenId =
    el
      [ Region.heading 3
      , paddingXY 0 8
      , Font.size 24
      , Font.bold
      ]
      <|
          text ("#" ++ (toString tokenId))

viewEmoji : BigInt -> Element msg
viewEmoji tokenId =
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
                , viewMintButton
                ]
