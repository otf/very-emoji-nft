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
import Html exposing (Html)
import Http as Http exposing (Error)
import Json.Decode as Decode exposing (Value)
import Messages
import Config
import Task as Task exposing (attempt, perform)
import List.Extra exposing (unfoldr)
import Time


port walletSentry : (Decode.Value -> msg) -> Sub msg


port txOut : Decode.Value -> Cmd msg


port txIn : (Decode.Value -> msg) -> Sub msg


port connectWallet : () -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ walletSentry (WalletSentry.decodeToMsg GotFail GotWalletStatus)
        , TxSentry.listen model.txSentry
        , Time.every 1000 (always FetchContract)
        ]


type alias Model =
    { message : Maybe String
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
    | GotMintedTokenIds (Result Http.Error (List BigInt))
    | GotFail String
    | ConnectWalletButtonSpecific ConnectWalletButton.Msg


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


type alias Call =
    HttpProvider -> Address -> Cmd Msg

callMintedTokenIds : Call
callMintedTokenIds provider contract =
    VeryEmoji.mintedTokenIds contract
        |> Eth.call provider
        |> Task.attempt GotMintedTokenIds

zeroToUntil : BigInt -> BigInt -> Maybe (BigInt, BigInt)
zeroToUntil max n =
    if BigInt.gt max n then
        Just (n, BigInt.add n (BigInt.fromInt 1))
    else
        Nothing

callContract : Model -> List Call -> ( Model -> Model ) -> ( Model, Cmd Msg )
callContract model callList updateModel =
    case model.contractAddress of
        Just contractAddr ->
            let
                batch =
                    callList
                    |> List.map (\call -> call model.provider contractAddr)
                    |> Cmd.batch
            in
            ( updateModel model, batch )

        Nothing ->
            ( model, Cmd.none )

updateMessage : Maybe String -> Model -> Model
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
                    , callMintedTokenIds model.provider contractAddr
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
            let
                updateModel =
                    updateMinting tokenId False
                    >> updateMessage (Messages.successOfMint tx.hash)
            in
            callContract model [ callMintedTokenIds ] updateModel

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
            (updateModel model, Cmd.none)

        GotMintedTokenIds (Ok mintedTokenIds) ->
            let
                updateModel m =
                    mintedTokenIds
                    |> List.foldl (\tokenId aModel -> updateMinted tokenId True aModel) m
            in
            callContract model [] updateModel

        GotMintedTokenIds (Err _) ->
            (model, Cmd.none)

        GotFail detailMessage ->
            (model |> updateMessage (Messages.unknownError detailMessage), Cmd.none)

        ConnectWalletButtonSpecific subMsg ->
            ({ model
            | connectWalletButtonModel =
                ConnectWalletButton.update subMsg model.connectWalletButtonModel
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
            |> List.map Emoji.view
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
