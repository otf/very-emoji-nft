module Components.Emoji exposing (view)

import BigInt exposing (BigInt, toString)
import ColorSchemes
import Components.MintButton as MintButton
import Config
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Eth.Types exposing (Address)
import Html.Attributes as RawAttrs


viewIpfsImage : BigInt -> Element msg
viewIpfsImage tokenId =
    image
        [ width fill
        , height (fill |> minimum 126)
        ]
        { src = Config.imageUrl tokenId
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
          text ("Very Emoji " ++ "#" ++ (toString tokenId))

view : (BigInt -> MintButton.Model msg) -> BigInt -> Element msg
view mkMintModel tokenId =
    el
        [ ColorSchemes.emojiBackgroundColor
        , ColorSchemes.emojiForegroundColor
        , Border.width 3
        , htmlAttribute <| RawAttrs.style "border-color" "#c0c0c0 #000 #c0c0c0 #000 #c0c0c0"
        , width (fill |> minimum 198)
        , height (fill |> minimum 274)
        ]
        <|
            column
                [ width fill
                , spacing 16
                , padding 16
                ]
                [ viewTokenId tokenId
                , row []
                    [ el [ width <| fillPortion 1 ] Element.none
                    , el [ width <| fillPortion 6 ] <| viewIpfsImage tokenId
                    , el [ width <| fillPortion 1 ] Element.none
                    ]
                , MintButton.view
                    <| mkMintModel tokenId
                ]
