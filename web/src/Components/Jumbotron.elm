module Components.Jumbotron exposing (viewJumbotron)

import ColorSchemes
import Element exposing (..)
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Eth.Types exposing (Address)
import Eth.Utils exposing (addressToString)


viewJumbotron : (Element msg -> Element msg) -> Element msg
viewJumbotron wrapContainer =
    el
        [ width fill
        , ColorSchemes.jumbotronBackgroundColor
        , ColorSchemes.jumbotronForegroundColor
        ]
        <|
            wrapContainer
              <| textColumn 
                  [ width fill
                  , paddingXY 0 32
                  , spacing 32 
                  ]
                  [ paragraph
                      [ Region.heading 2
                      , Font.bold 
                      , Font.size 32
                      ] 
                      [ text "フリーミントNFT"
                      , text "『Very Emoji』"
                      ]
                  , paragraph []
                      [ text "Very Emojiは、NFTアーティストの@sizuku_ethが練習として制作したフリーミントNFTです。"
                      , text "このNFTは、シンプルなERC-721 独自コントラクトによってミントされます。"
                      ]
                  ]
