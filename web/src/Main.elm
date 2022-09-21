port module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Input as Input
import Element.Region as Region
import Eth.Net as Net exposing (NetworkId(..), toNetworkId)
import Eth.Sentry.Tx as TxSentry exposing (TxSentry)
import Eth.Sentry.Wallet as WalletSentry exposing (WalletSentry)
import Eth.Types exposing (..)
import Eth.Utils as EthUtils
import Html exposing (Html)
import Http as Http exposing (Error)
import Json.Decode as Decode exposing (Value)


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
    , walletAddress : Maybe Address
    , provider : HttpProvider
    }


type Msg
    = TxSentryMsg TxSentry.Msg
    | ConnectWallet
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
      , walletAddress = Nothing
      , provider = provider
      }
    , Cmd.none
    )


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


content : Model -> Element msg
content { walletAddress, message } =
    let
        mintFrame =
            case walletAddress of
                Just _ ->
                    Input.button
                        [ centerX
                        ]
                        { label = text "Mint", onPress = Nothing }

                Nothing ->
                    text message
    in
    column
        [ centerX
        ]
        [ mintFrame
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
