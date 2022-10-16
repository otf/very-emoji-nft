port module Main exposing (..)

import BigInt exposing (BigInt)
import Browser
import Components.ConnectWalletButton as ConnectWalletButton
import Components.Jumbotron exposing (viewJumbotron)
import Components.Gallery exposing (viewGallery)
import Components.Emoji as Emoji
import Components.MintButton as MintButton
import Layout
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
import Eth.Encode as EthEncode
import Eth.Abi.Decode as EthAbiDecode
import Html exposing (Html)
import Http as Http exposing (Error)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value, Decoder)
import Messages
import Config
import Task as Task exposing (attempt, perform)
import List.Extra exposing (unfoldr)
import Time


encodeCallData : Value -> Value
encodeCallData params =
    Encode.object
        [ ( "params", params )
        ]

encodeCall : Call a -> Value
encodeCall callData =
    EthEncode.listOfMaybesToVal
        [ ( "to", Maybe.map EthEncode.address callData.to )
        , ( "from", Maybe.map EthEncode.address callData.from )
        , ( "gas", Maybe.map EthEncode.hexInt callData.gas )
        , ( "gasPrice", Maybe.map EthEncode.bigInt callData.gasPrice )
        , ( "value", Maybe.map EthEncode.bigInt callData.value )
        , ( "data", Maybe.map EthEncode.hex callData.data )
        , ( "nonce", Maybe.map EthEncode.hexInt callData.nonce )
        ]

ethCall : (Result String a -> msg) -> Call a -> Cmd msg
ethCall tagger params =
    let
        paramsVal =
            encodeCall params
    in
    callOut (encodeCallData paramsVal)

mintedTokenIdsResponseDecoder : Decoder (List BigInt)
mintedTokenIdsResponseDecoder =
    Decode.field "data"
        <| EthAbiDecode.toElmDecoder (EthAbiDecode.dynamicArray EthAbiDecode.uint)
    -- todo

errorDecoder : Decoder String
errorDecoder =
    Decode.field "error" Decode.string

decodeCallData : Decoder a -> Value -> Result String a
decodeCallData decoder val =
    case Decode.decodeValue decoder val of
        Ok result ->
            Ok result
        Err _ ->
            case Decode.decodeValue errorDecoder val of
                Ok error ->
                    (Err <| "Problem call. error message is:" ++ error)
                Err error2 ->
                    Err "Error decoding call data(error object)"

listenCall : (Result String a -> msg) -> Decoder a -> Sub msg
listenCall tagger decoder =
    Sub.map tagger (callIn (decodeCallData decoder))

port walletSentry : (Decode.Value -> msg) -> Sub msg


port callOut : Decode.Value -> Cmd msg


port callIn : (Decode.Value -> msg) -> Sub msg


port txOut : Decode.Value -> Cmd msg


port txIn : (Decode.Value -> msg) -> Sub msg


port connectWallet : () -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ walletSentry (WalletSentry.decodeToMsg GotFail GotWalletStatus)
        , TxSentry.listen model.txSentry
        , listenCall GotMintedTokenIds mintedTokenIdsResponseDecoder
        , Time.every 1000 (always FetchContract)
        ]


type alias Model =
    { message : Maybe (Element Msg)
    , txSentry : TxSentry Msg
    , contractAddress : Maybe Address
    , walletAddress : Maybe Address
    , provider : HttpProvider
    , connectWalletButtonModel : ConnectWalletButton.Model Msg
    , mintButtonModels : List (MintButton.Model Msg)
    }


type Msg
    = TxSentryMsg TxSentry.Msg
    | ConnectWallet
    | FetchContract
    | Mint BigInt
    | GotMint BigInt (Result String Tx)
    | GotWalletStatus WalletSentry
    | GotMintedTokenIds (Result String (List BigInt))
    | GotFail String
    | ConnectWalletButtonSpecific ConnectWalletButton.Msg
    | MintButtonSpecific BigInt MintButton.Msg


init : Int -> ( Model, Cmd Msg )
init networkId =
    let
        provider =
            Net.toNetworkId networkId
                |> toProvider

        zeroToMaxSupply =
            unfoldr (zeroToUntil Config.maxSupply) (BigInt.fromInt 0)

        mintButtonModels =
            zeroToMaxSupply
            |> List.map (MintButton.init Mint False False)
    in
    ( { message = Messages.pleaseConnectWallet
      , txSentry = TxSentry.init ( txOut, txIn ) TxSentryMsg provider
      , contractAddress = Nothing
      , walletAddress = Nothing
      , provider = provider
      , connectWalletButtonModel = ConnectWalletButton.init ConnectWallet
      , mintButtonModels = mintButtonModels
      }
    , Task.perform (always FetchContract) (Task.succeed ())
    )


mint : TxSentry Msg -> Address -> Address -> BigInt -> ( TxSentry Msg, Cmd Msg )
mint sentry from contract tokenId =
    VeryEmoji.mint from contract tokenId
        |> Eth.toSend
        |> TxSentry.send (GotMint tokenId) sentry

callMintedTokenIds : Address -> Cmd Msg
callMintedTokenIds contract =
    VeryEmoji.mintedTokenIds contract
        |> ethCall GotMintedTokenIds

zeroToUntil : BigInt -> BigInt -> Maybe (BigInt, BigInt)
zeroToUntil max n =
    if BigInt.gt max n then
        Just (n, BigInt.add n (BigInt.fromInt 1))
    else
        Nothing

updateMessage : Maybe (Element Msg) -> Model -> Model
updateMessage message model =
    { model
    | message = message
    }


updateMinting : BigInt -> Bool -> Model -> Model
updateMinting tokenId isMinting model =
    { model
    | mintButtonModels =
        model.mintButtonModels
        |> List.map
            (\mintButtonModel ->
                if mintButtonModel.tokenId == tokenId then
                    { mintButtonModel
                    | isMinting = isMinting
                    }
                else
                    mintButtonModel
            )
    }


updateMinted : BigInt -> Bool -> Model -> Model
updateMinted tokenId isMinted model =
    { model
    | mintButtonModels =
        model.mintButtonModels
        |> List.map
            (\mintButtonModel ->
                if mintButtonModel.tokenId == tokenId then
                    { mintButtonModel
                    | isMinted = isMinted
                    }
                else
                    mintButtonModel
            )
    }


updateWalletStatus : Maybe Address -> HttpProvider -> Model -> Model
updateWalletStatus walletAddress provider model =
    { model
    | walletAddress = walletAddress
    , provider = provider
    , mintButtonModels =
        model.mintButtonModels
        |> List.map
            (\mintButtonModel ->
                { mintButtonModel
                | walletAddress = walletAddress
                }
            )
    }


updateTxSentry : TxSentry Msg -> Model -> Model
updateTxSentry txSentry model =
    { model
    | txSentry = txSentry
    }


updateContractAddress : Maybe Address -> Model -> Model
updateContractAddress contractAddress model =
    { model
    | contractAddress = contractAddress
    }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        TxSentryMsg subMsg ->
            let
                (subModel, subCmd) =
                    TxSentry.update subMsg model.txSentry
            in
            (model |> updateTxSentry subModel, subCmd)

        ConnectWallet ->
            (model, connectWallet ())

        FetchContract ->
            case Config.contractAddress of
                Ok contractAddr ->
                    ({ model
                        | contractAddress = Just contractAddr
                     }
                    , callMintedTokenIds contractAddr
                    )

                Err detailMessage ->
                    (model |> updateMessage (Messages.unknownError detailMessage), Cmd.none)

        Mint tokenId ->
            case ( model.walletAddress, model.contractAddress ) of
                ( Just walletAddr, Just contractAddr ) ->
                    let
                        (newTxSentry, mintCmd) =
                            mint model.txSentry walletAddr contractAddr tokenId
                        updateModel =
                            updateTxSentry newTxSentry
                            >> updateMinting tokenId True
                    in
                    (model |> updateModel, mintCmd)

                _ ->
                    (model |> updateMessage Messages.errorOfFetchContract, Cmd.none)

        GotMint tokenId (Ok tx) ->
            case Config.contractAddress of
                Ok contractAddr ->
                    let
                        updateModel =
                            updateMinting tokenId False
                            >> updateMessage (Messages.successOfMint tx.hash)
                            >> updateContractAddress (Just contractAddr)
                    in
                    (model |> updateModel
                    , callMintedTokenIds contractAddr
                    )

                Err detailMessage ->
                    (model |> updateMessage (Messages.unknownError detailMessage), Cmd.none)

        GotMint tokenId (Err detailMessage) ->
            let
                updateModel =
                    updateMinting tokenId False
                    >> updateMessage (Messages.unknownError detailMessage)
            in
            (model |> updateModel, Cmd.none)

        GotWalletStatus walletSentry_ ->
            let
                message =
                    case walletSentry_.account of
                        Just _ ->
                            Nothing

                        Nothing ->
                            Messages.pleaseConnectWallet
                updateModel =
                    updateWalletStatus walletSentry_.account (toProvider walletSentry_.networkId)
                    >> updateMessage message
            in
            (model |> updateModel, Cmd.none)

        GotMintedTokenIds (Ok mintedTokenIds) ->
            let
                updateModel m =
                    mintedTokenIds
                    |> List.foldl (\tokenId aModel -> updateMinted tokenId True aModel) m
            in
            (model |> updateModel, Cmd.none)

        GotMintedTokenIds (Err _) ->
            (model, Cmd.none)

        GotFail detailMessage ->
            (model |> updateMessage (Messages.unknownError detailMessage), Cmd.none)

        ConnectWalletButtonSpecific subMsg ->
            ({ model
            | connectWalletButtonModel =
                ConnectWalletButton.update subMsg model.connectWalletButtonModel
            }, Cmd.none)

        MintButtonSpecific tokenId subMsg ->
            ({ model
            | mintButtonModels =
                model.mintButtonModels
                |> List.map
                    (\mintButtonModel ->
                        if mintButtonModel.tokenId == tokenId then
                            mintButtonModel
                            |> MintButton.update subMsg
                        else
                            mintButtonModel
                    )
            }, Cmd.none)


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
        emojiList =
            model.mintButtonModels
            |> List.map (\mintButtonModel -> Emoji.view (MintButtonSpecific mintButtonModel.tokenId) mintButtonModel)
    in
    Layout.toHtml
        <|
            { connectWalletButton =
                ConnectWalletButton.view
                    (ConnectWalletButton.updateWalletAddress model.walletAddress model.connectWalletButtonModel)
                    ConnectWalletButtonSpecific
            , jumbotron = viewJumbotron
            , gallery = viewGallery emojiList
            , message = model.message
            }


main : Program Int Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
