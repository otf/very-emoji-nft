port module Main exposing (..)

import BigInt exposing (BigInt)
import Browser
import Contracts.VeryEmoji as VeryEmoji exposing (mint)
import Element exposing (..)
import Element.Input as Input
import Element.Region as Region
import Eth as Eth exposing (sendTx, toSend)
import Eth.Net as Net exposing (NetworkId(..), toNetworkId)
import Eth.Sentry.Tx as TxSentry exposing (TxSentry)
import Eth.Sentry.Wallet as WalletSentry exposing (WalletSentry)
import Eth.Types exposing (..)
import Eth.Utils as EthUtils exposing (toAddress, txHashToString)
import Html exposing (Html)
import Http as Http exposing (Error)
import Json.Decode as Decode exposing (Value)
import Task as Task exposing (attempt)


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
    }


type Msg
    = TxSentryMsg TxSentry.Msg
    | ConnectWallet
    | Mint
    | GotContractAddress String
    | GotMint (Result Http.Error TxHash)
    | GotWalletStatus WalletSentry
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
      }
    , Cmd.none
    )


mint : HttpProvider -> Address -> BigInt -> Cmd Msg
mint provider contract tokenId =
    VeryEmoji.mint contract tokenId
        |> Eth.toSend
        |> Eth.sendTx provider
        |> Task.attempt GotMint


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

        Mint ->
            let
                contractAddress =
                    EthUtils.toAddress model.inputContractAddress
            in
            case contractAddress of
                Ok contractAddr ->
                    ( model, mint model.provider contractAddr (BigInt.fromInt 1) )

                Err message ->
                    ( { model | message = message }, Cmd.none )

        GotContractAddress strContractAddress ->
            ( { model | inputContractAddress = strContractAddress }, Cmd.none )

        GotMint (Ok txHash) ->
            ( { model | message = "You got a NFT!: " ++ EthUtils.txHashToString txHash }, Cmd.none )

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

        GotFail message ->
            ( { model | message = message }, Cmd.none )


toProvider : NetworkId -> HttpProvider
toProvider networkId =
    case networkId of
        Mainnet ->
            "https://mainnet.infura.io/"

        Private 31337 ->
            "http://localhost:8545/"

        _ ->
            "UnknownEthNetwork"


logo : Element msg
logo =
    el
        [ width <| px 80
        , height <| px 40
        ]
    <|
        el [ Region.heading 1 ] <|
            text "Very Emoji"


header : Model -> Element Msg
header { walletAddress } =
    let
        connectWalletText =
            case walletAddress of
                Just addr ->
                    EthUtils.addressToString addr

                Nothing ->
                    "CONNECT WALLET"
    in
    row
        [ width fill
        , padding 20
        , spacing 20
        ]
        [ logo
        , Input.button
            [ alignRight
            ]
            { label = text connectWalletText
            , onPress = Just ConnectWallet
            }
        ]


content : Model -> Element Msg
content { inputContractAddress, walletAddress, message } =
    let
        contractAddressInput =
            Input.text
                [ centerX
                ]
                { onChange = GotContractAddress
                , text = inputContractAddress
                , placeholder = Nothing
                , label = Input.labelLeft [] <| text "Contract Address: "
                }

        mintFrame =
            case walletAddress of
                Just _ ->
                    Input.button
                        [ centerX
                        ]
                        { label = text "Mint", onPress = Just Mint }

                Nothing ->
                    Element.none
    in
    column
        [ centerX
        ]
        [ contractAddressInput
        , mintFrame
        , text message
        ]


mainLayout : Model -> Html Msg
mainLayout model =
    layout [ width fill, height fill ] <|
        column [ width fill ]
            [ header model
            , content model
            ]


main : Program Int Model Msg
main =
    Browser.element
        { init = init
        , view = mainLayout
        , update = update
        , subscriptions = subscriptions
        }
