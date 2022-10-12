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
                  , paragraph
                      [ Region.heading 3
                      , Font.size 16
                      , Font.bold
                      , paddingXY 0 8
                      ]
                      [ text "注意事項"
                      ]
                  , paragraph [ Font.size 16 ]
                      [ text "* ミント代はかからないけど、ガス代は必要だよ。ウォレットにイーサ(ETH)を入れておいてね。"
                      ]
                  , paragraph [ Font.size 16 ]
                      [ text "* 予告なく公開を終了するかも。ずっと鑑賞したい人は、自分でIPFSにPinしてね。"
                      ]
                  , paragraph [ Font.size 16 ]
                      [ text "* 絵文字がモチーフだけど、実際の文字としては使えないよ。"
                      ]
                  , paragraph
                      [ Region.heading 3
                      , Font.size 16
                      , Font.bold
                      , paddingXY 0 8
                      ]
                      [ text "ライセンス"
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
