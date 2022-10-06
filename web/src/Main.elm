port module Main exposing (..)

import BigInt exposing (BigInt)
import Browser
import Components.ConnectWalletButton exposing (viewConnectWalletButton)
import Components.Jumbotron exposing (viewJumbotron)
import Components.Gallery exposing (viewGallery)
import Components.Emoji exposing (viewEmoji)
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
import Layout
import Task as Task exposing (attempt, perform)
import List.Extra exposing (unfoldr)


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
    , mintedTokenIds : List BigInt
    }


type Msg
    = TxSentryMsg TxSentry.Msg
    | ConnectWallet
    | FetchContract
    | Mint BigInt
    | GotContractAddress String
    | GotMint (Result String Tx)
    | GotWalletStatus WalletSentry
    | GotTotalSupply (Result Http.Error BigInt)
    | GotMaxSupply (Result Http.Error BigInt)
    | GotTokenByIndex (Result Http.Error BigInt)
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
      , inputContractAddress = "0x0a76Eb09d6ae4e7df12C670b8eF336FcBf03F8dE"
      , contractAddress = Nothing
      , walletAddress = Nothing
      , provider = provider
      , totalSupply = Nothing
      , maxSupply = Nothing
      , mintedTokenIds = []
      }
    , Task.perform (always FetchContract) (Task.succeed ())
    )


mint : TxSentry Msg -> Address -> Address -> BigInt -> ( TxSentry Msg, Cmd Msg )
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


callTokenByIndex : HttpProvider -> Address -> BigInt -> Cmd Msg
callTokenByIndex provider contract index =
    VeryEmoji.tokenByIndex contract index
        |> Eth.call provider
        |> Task.attempt GotTokenByIndex


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

        Mint tokenId ->
            case ( model.walletAddress, model.contractAddress, model.totalSupply ) of
                ( Just walletAddr, Just contractAddr, Just totalSupply ) ->
                    let
                        ( newTxSentry, mintCmd ) =
                            mint model.txSentry walletAddr contractAddr tokenId
                    in
                    ( { model | txSentry = newTxSentry }, mintCmd )

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
            case model.contractAddress of
                Just contractAddr ->
                    let
                        incrementUntilTotalSupply n =
                            if BigInt.gt totalSupply n then
                                Just (n, BigInt.add n (BigInt.fromInt 1))
                            else
                                Nothing
                        cmds =
                            unfoldr incrementUntilTotalSupply (BigInt.fromInt 0)
                            |> List.map (callTokenByIndex model.provider contractAddr)

                    in

                    ( { model | totalSupply = Just totalSupply, mintedTokenIds = [] }, Cmd.batch cmds )
                Nothing ->
                    ( { model | message = "Fetching the contract error has occured." }, Cmd.none )

        GotTotalSupply (Err _) ->
            ( { model | message = "Fetching the contract error has occured." }, Cmd.none )

        GotMaxSupply (Ok maxSupply) ->
            ( { model | maxSupply = Just maxSupply }, Cmd.none )

        GotMaxSupply (Err _) ->
            ( { model | message = "Fetching the contract error has occured." }, Cmd.none )

        GotTokenByIndex (Ok tokenId) ->
            ( { model | mintedTokenIds = tokenId :: model.mintedTokenIds }, Cmd.none )

        GotTokenByIndex (Err _) ->
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


view : Model -> Html Msg
view model =
    let
        totalSupply =
            model.totalSupply
            |> Maybe.withDefault (BigInt.fromInt 0)
        emojiList =
            List.range 1 288
            |> List.map BigInt.fromInt
            |> List.map (viewEmoji Mint (\tokenId -> List.any ((==) tokenId) model.mintedTokenIds))
    in
    Layout.viewLayout
        <|
            { connectWalletButton = viewConnectWalletButton model.walletAddress ConnectWallet
            , jumbotron = viewJumbotron
            , gallery = viewGallery emojiList
            }


main : Program Int Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
