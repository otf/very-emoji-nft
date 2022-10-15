module Components.ConnectWalletButton exposing (view, init, updateWalletAddress, update, Model, Msg(..))

import ColorSchemes
import Element exposing (..)
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Element.Events as Events
import Eth.Types exposing (Address)
import Eth.Utils exposing (addressToString)


type ButtonState
    = Default
    | Pressed


type alias Model msg =
    { state : ButtonState
    , isHover : Bool
    , onPress : msg
    , walletAddress : Maybe Address
    }


type Msg
    = OnMouseDown
    | OnMouseUp
    | OnMouseEnter
    | OnMouseLeave


init : msg -> Model msg
init msg =
    { state = Default
    , isHover = False
    , onPress = msg
    , walletAddress = Nothing
    }


updateWalletAddress : Maybe Address -> Model msg -> Model msg
updateWalletAddress walletAddress model =
    { model
    | walletAddress = walletAddress
    }


update : Msg -> Model msg -> Model msg
update msg model =
    case msg of
        OnMouseDown ->
            { model
            | state = Pressed
            }
        OnMouseUp ->
            { model
            | state = Default
            }
        OnMouseEnter ->
            { model
            | isHover = True
            }
        OnMouseLeave ->
            { model
            | isHover = False
            }


view : Model msg -> (Msg -> msg) -> Element msg
view model toMsg =
    let
        buttonText =
            case model.walletAddress of
                Just walletAddr ->
                    let
                        strAddr =
                            addressToString walletAddr
                    in
                    (String.left 6 strAddr) ++ "..." ++ (String.right 4 strAddr)
                Nothing ->
                    "ウォレットを接続"
    in
    Input.button
        ([ padding 12
        , width fill
        , Font.center
        , Font.size 16
        , Font.bold
        , Font.family
            [ Font.external
                { name = "DotGothic16"
                , url = "https://fonts.googleapis.com/css2?family=DotGothic16"
                }
            , Font.sansSerif
            ]
        , Border.width 2
        , Border.rounded 8
        , Border.color <| rgb255 166 43 113
        , ColorSchemes.buttonForegroundColor
        , ColorSchemes.buttonBackgroundColor
        , focused
            [
            ]
        , Events.onMouseDown <| toMsg OnMouseDown
        , Events.onMouseUp <| toMsg OnMouseUp
        , Events.onMouseLeave <| toMsg OnMouseLeave
        , Events.onMouseEnter <| toMsg OnMouseEnter
        ] ++
            (case (model.isHover, model.state) of
                (False, Default) ->
                    [ Border.shadow
                        { offset = (0.0, 4.0)
                        , size = 0.0
                        , blur = 0.0
                        , color = rgb255 166 43 113
                        }
                    ]
                (True, Default) ->
                    [ moveDown 4.0
                    ]
                (True, Pressed) ->
                    [ moveDown 4.0
                    ]
                (False, Pressed) ->
                    [ Border.shadow
                        { offset = (0.0, 4.0)
                        , size = 0.0
                        , blur = 0.0
                        , color = rgb255 166 43 113
                        }
                    ]
            ))

        { onPress = Just model.onPress
        , label = text buttonText
        }
