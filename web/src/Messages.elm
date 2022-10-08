module Messages exposing (..)

import Eth.Types exposing (TxHash)
import Eth.Utils exposing (txHashToString)

sorry : String
sorry =
    "なにか問題があるようです。ご迷惑をおかけして申し訳ございません。"
        ++ "@sizuku_eth までご連絡ください。"

pleaseConnectWallet : Maybe String
pleaseConnectWallet =
    Just "ウォレットを接続してください。"

errorOfFetchContract : Maybe String
errorOfFetchContract =
    Just 
        <| sorry
        ++ "詳細なエラーメッセージ(コントラクトの取得に失敗しました)"

successOfMint : TxHash -> Maybe String
successOfMint txHash =
    Just <| "ミントに成功しました！: " ++ (txHashToString txHash)

unknownError : String -> Maybe String
unknownError innerMessage =
    Just
        <| sorry
        ++ "詳細なエラーメッセージ("
        ++ innerMessage
        ++ ")"
