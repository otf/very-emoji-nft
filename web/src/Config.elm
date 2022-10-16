module Config exposing (..)

import String exposing (padLeft)
import BigInt exposing (BigInt)
import Eth.Types exposing (..)
import Eth.Utils as EthUtils

maxSupply : BigInt
maxSupply =
    BigInt.fromInt 88

rawContractAddress : String
rawContractAddress =
    "0x4bb1cbAd0e7535CF31393e5bD7141F63D8EF2F05"

contractAddress : Result String Address
contractAddress =
    EthUtils.toAddress rawContractAddress


linkForEtherscan : String
linkForEtherscan =
    "https://etherscan.io/address/" ++ rawContractAddress


imageUrl : BigInt -> String
imageUrl tokenId =
    let
        strTokenId =
            BigInt.toString tokenId |> padLeft 3 '0'
    in
    "dist/images/" ++ strTokenId ++ ".svg"
