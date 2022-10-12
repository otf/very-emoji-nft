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
import Html.Attributes as RawAttr


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
                  , paddingXY 0 80
                  ]
                  [ paragraph
                      [ Region.heading 2
                      , Font.bold 
                      , Font.size 32
                      ] 
                      [ text "フリーミントNFT"
                      , text "『Very Emoji』"
                      ]
                  , paragraph 
                      [ Font.size 24 
                      , paddingXY 0 32
                      ]
                      [ text "Very Emojiは、NFTアーティストの@sizuku_ethが練習として制作したフリーミントNFT(ERC-721準拠)です。"
                      ]
                  , paragraph [ Font.size 16 ]
                      [ text "* ミント代はかかりませんが、ガス代のイーサ(ETH)は別途必要です。"
                      ]
                  , paragraph [ Font.size 16 ]
                      [ text "* ミントに必要なWL(ウェイトリスト)はありません。"
                      ]
                  , paragraph [ Font.size 16 ]
                      [ text "* 本作品の公開は、予告なく終了する場合があります。本作品を永続的に使いたい場合は、ご自身でIPFSにPinしてください。"
                      ]
                  , paragraph [ Font.size 16 ]
                      [ text "* 本作品は、絵文字をモチーフとしていますが、実際に文字として使用することはできません。"
                      ]
                  , paragraph [ Font.size 16 ]
                      [ text "* @sizuku_ethは、法律上可能な範囲で、Very Emojiの著作権および関連・付随する権利をすべて放棄しています。本作品は、日本から出版されています。"
                      , newTabLink [ htmlAttribute (RawAttr.attribute "rel" "license") ]
                          { url = "https://creativecommons.org/publicdomain/zero/1.0/legalcode.ja"
                          , label =
                              image []
                                  { src = "https://licensebuttons.net/p/zero/1.0/80x15.png"
                                  , description = "CC0"
                                  }
                          }
                      ]
                  ]
