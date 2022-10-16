module Messages exposing (..)

import Element exposing (..)
import Element.Font as Font
import Eth.Types exposing (TxHash)
import Eth.Utils exposing (txHashToString)

sorry : String
sorry =
    "⚠️ なにか問題があるようです。ご迷惑をおかけして申し訳ございません。"
        ++ "@sizuku_eth までご連絡ください。"

pleaseConnectWallet : Maybe (Element msg)
pleaseConnectWallet =
    Just <| text "⚠️ ウォレットを接続してください。"

errorOfFetchContract : Maybe (Element msg)
errorOfFetchContract =
    Just 
        <| text (sorry
            ++ "詳細なエラーメッセージ(コントラクトの取得に失敗しました)")

successOfMint : TxHash -> Maybe (Element msg)
successOfMint txHash =
    let
        strHash =
            txHashToString txHash
    in
    Just <|
        paragraph []
            [ text "✨ ミントに成功しました: "
            , newTabLink [ Font.italic, Font.underline ]
                { url = "https://etherscan.io/tx/" ++ strHash
                , label = text "ブロックチェーンエクスプローラーで確認する"
                }
            ]

unknownError : String -> Maybe (Element msg)
unknownError innerMessage =
    Just
        <| text (sorry
            ++ "詳細なエラーメッセージ("
            ++ innerMessage
            ++ ")")
