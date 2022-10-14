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
    "0xE94215Ee7e25a1aCB58a9D5406db930ee729700b"

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
    "https://ipfs.io/ipfs/QmNMvGKmP4FvR5BTh8m2hok9cUy8dpKVHRXXHvT79EQcdb/" ++ strTokenId ++ ".svg"
