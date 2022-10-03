port module Main exposing (..)

import BigInt exposing (BigInt)
import Browser
import Contracts.VeryEmoji as VeryEmoji exposing (mint)
import Element exposing (..)
import Element.Input as Input
import Element.Region as Region
import Eth as Eth
import Eth.Net as Net exposing (NetworkId(..))
import Eth.Sentry.Tx as TxSentry exposing (TxSentry)
import Eth.Sentry.Wallet as WalletSentry exposing (WalletSentry)
import Eth.Types exposing (..)
import Eth.Utils as EthUtils
import Html exposing (Html)
import Http as Http exposing (Error)
import Json.Decode as Decode exposing (Value)
import Task as Task exposing (attempt)

import Layout


port walletSentry : (Decode.Value -> msg) -> Sub msg


port txOut : Decode.Value -> Cmd msg


port txIn : (Decode.Value -> msg) -> Sub msg


port connectWallet : () -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ walletSentry (WalletSentry.decodeToMsg GotFail GotWalletStatus)
        , TxSentry.listen model.txSentry
        ]


type alias Model =
    { message : String
    , txSentry : TxSentry Msg
    , inputContractAddress : String
    , contractAddress : Maybe Address
    , walletAddress : Maybe Address
    , provider : HttpProvider
    , totalSupply : Maybe BigInt
    , maxSupply : Maybe BigInt
    }


type Msg
    = TxSentryMsg TxSentry.Msg
    | ConnectWallet
    | FetchContract
    | Mint
    | GotContractAddress String
    | GotMint (Result String Tx)
    | GotWalletStatus WalletSentry
    | GotTotalSupply (Result Http.Error BigInt)
    | GotMaxSupply (Result Http.Error BigInt)
    | GotFail String


init : Int -> ( Model, Cmd Msg )
init networkId =
    let
        provider =
            Net.toNetworkId networkId
                |> toProvider
    in
    ( { message = "Please connect your wallet."
      , txSentry = TxSentry.init ( txOut, txIn ) TxSentryMsg provider
      , inputContractAddress = ""
      , contractAddress = Nothing
      , walletAddress = Nothing
      , provider = provider
      , totalSupply = Nothing
      , maxSupply = Nothing
      }
    , Cmd.none
    )


mint : TxSentry Msg -> Address -> Address -> BigInt -> (TxSentry Msg, Cmd Msg)
mint sentry from contract tokenId =
    VeryEmoji.mint from contract tokenId
        |> Eth.toSend
        |> TxSentry.send GotMint sentry


imageUrl : BigInt -> String
imageUrl tokenId =
    "http://localhost:8080/ipfs/QmU8iCM7QYECrWtWjKUN6QZcu6Z4Se9gM1CjDtsUAVc4AX/" ++ BigInt.toString tokenId ++ ".svg"


callTotalSupply : HttpProvider -> Address -> Cmd Msg
callTotalSupply provider contract =
    VeryEmoji.totalSupply contract
        |> Eth.call provider
        |> Task.attempt GotTotalSupply


callMaxSupply : HttpProvider -> Address -> Cmd Msg
callMaxSupply provider contract =
    VeryEmoji.maxSupply contract
        |> Eth.call provider
        |> Task.attempt GotMaxSupply


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TxSentryMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    TxSentry.update subMsg model.txSentry
            in
            ( { model | txSentry = subModel }, subCmd )

        ConnectWallet ->
            ( model, connectWallet () )

        FetchContract ->
            let
                contractAddress =
                    EthUtils.toAddress model.inputContractAddress
            in
            case contractAddress of
                Ok contractAddr ->
                    ( { model
                        | contractAddress = Just contractAddr
                      }
                    , Cmd.batch
                        [ callTotalSupply model.provider contractAddr
                        , callMaxSupply model.provider contractAddr
                        ]
                    )

                Err message ->
                    ( { model | message = message }, Cmd.none )

        Mint ->
            case (model.walletAddress, model.contractAddress, model.totalSupply ) of
                ( Just walletAddr, Just contractAddr, Just totalSupply ) ->
                    let
                        (newTxSentry, mintCmd) =
                            mint model.txSentry walletAddr contractAddr (BigInt.add totalSupply (BigInt.fromInt 1))
                    in
                    ( { model | txSentry = newTxSentry }, mintCmd)

                _ ->
                    ( { model | message = "Fetching the contract error has occured." }, Cmd.none )

        GotContractAddress strContractAddress ->
            ( { model | inputContractAddress = strContractAddress }, Cmd.none )

        GotMint (Ok tx) ->
            let
                contractAddress =
                    EthUtils.toAddress model.inputContractAddress
            in
            case contractAddress of
                Ok contractAddr ->
                    ( { model
                        | message = "You got a NFT!: " ++ EthUtils.txHashToString tx.hash
                      }
                    , callTotalSupply model.provider contractAddr
                    )

                Err message ->
                    ( { model | message = message }, Cmd.none )

        GotMint (Err _) ->
            ( { model | message = "Minting error has occured." }, Cmd.none )

        GotWalletStatus walletSentry_ ->
            let
                message =
                    case walletSentry_.account of
                        Just _ ->
                            ""

                        Nothing ->
                            "Please connect your wallet."
            in
            ( { model
                | walletAddress = walletSentry_.account
                , provider = toProvider walletSentry_.networkId
                , message = message
              }
            , Cmd.none
            )

        GotTotalSupply (Ok totalSupply) ->
            ( { model | totalSupply = Just totalSupply }, Cmd.none )

        GotTotalSupply (Err _) ->
            ( { model | message = "Fetching the contract error has occured." }, Cmd.none )

        GotMaxSupply (Ok maxSupply) ->
            ( { model | maxSupply = Just maxSupply }, Cmd.none )

        GotMaxSupply (Err _) ->
            ( { model | message = "Fetching the contract error has occured." }, Cmd.none )

        GotFail message ->
            ( { model | message = message }, Cmd.none )


toProvider : NetworkId -> HttpProvider
toProvider networkId =
    case networkId of
        Mainnet ->
            "https://mainnet.infura.io/"

        Private 31337 ->
            "http://localhost:8545/"

        Private 80001 ->
            "https://matic-mumbai.chainstacklabs.com/"

        _ ->
            "UnknownEthNetwork"


main : Program Int Model Msg
main =
    Browser.element
        { init = init
        , view = \model -> Layout.viewLayout
        , update = update
        , subscriptions = subscriptions
        }
