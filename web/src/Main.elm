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
    | GotMint (Result Http.Error TxHash)
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


mint : HttpProvider -> Address -> BigInt -> Cmd Msg
mint provider contract tokenId =
    VeryEmoji.mint contract tokenId
        |> Eth.toSend
        |> Eth.sendTx provider
        |> Task.attempt GotMint


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
            case ( model.contractAddress, model.totalSupply ) of
                ( Just contractAddr, Just totalSupply ) ->
                    ( model, mint model.provider contractAddr (BigInt.add totalSupply (BigInt.fromInt 1)) )

                _ ->
                    ( { model | message = "Fetching the contract error has occured." }, Cmd.none )

        GotContractAddress strContractAddress ->
            ( { model | inputContractAddress = strContractAddress }, Cmd.none )

        GotMint (Ok txHash) ->
            let
                contractAddress =
                    EthUtils.toAddress model.inputContractAddress
            in
            case contractAddress of
                Ok contractAddr ->
                    ( { model
                        | message = "You got a NFT!: " ++ EthUtils.txHashToString txHash
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


viewIpfsImage : BigInt -> Element msg
viewIpfsImage totalSupply =
    image
        [ centerX
        ]
        { src = imageUrl totalSupply
        , description = "Very Emoji NFT"
        }


viewSupply : BigInt -> BigInt -> Element msg
viewSupply totalSupply maxSupply =
    el
        [ centerX
        ]
    <|
        text <|
            BigInt.toString totalSupply
                ++ "/"
                ++ BigInt.toString maxSupply


viewNft : Model -> Element Msg
viewNft model =
    let
        mintButton =
            Input.button
                [ centerX ]
                { label = text "Mint", onPress = Just Mint }

        contractAddressInput =
            Input.text
                [ centerX
                ]
                { onChange = GotContractAddress
                , text = model.inputContractAddress
                , placeholder = Nothing
                , label = Input.labelLeft [] <| text "Contract Address: "
                }

        fetchContractButton =
            Input.button
                [ centerX ]
                { label = text "Fetch the contract", onPress = Just FetchContract }
    in
    case ( model.walletAddress, model.totalSupply, model.maxSupply ) of
        ( Just _, Just total, Just max ) ->
            let
                nextTokenId =
                    BigInt.add total (BigInt.fromInt 1)
            in
            if BigInt.lt total max then
                column
                    [ centerX ]
                    [ viewIpfsImage nextTokenId
                    , viewSupply nextTokenId max
                    , mintButton
                    ]

            else
                text "All NFTs are minted."

        ( Just _, _, _ ) ->
            column
                [ centerX ]
                [ contractAddressInput
                , fetchContractButton
                ]

        _ ->
            Element.none


content : Model -> Element Msg
content ({ inputContractAddress, walletAddress, message } as model) =
    column
        [ centerX
        ]
        [ viewNft model
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
