module Components.ConnectWalletButton exposing (view, init, updateWalletAddress, update, Model, Msg(..))

import ColorSchemes
import Element exposing (..)
import Element.Background as Background exposing (color)
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


viewLed : Bool -> Element msg
viewLed on =
    if on then
      el
          [ Border.shadow
              { offset = (0, 0)
              , size = 2.0
              , blur = 4.0
              , color = rgba255 0 161 75 0.5
              }
          , Border.rounded 32
          ]
          <| el
              [ width <| px 16
              , height <| px 16
              , Border.width 1
              , Border.rounded 32
              , Border.color <| rgb255 60 60 60
              , Background.color <| rgb255 0 161 75
              , Border.innerGlow (rgba255 255 255 255 0.3) 3.0
              ]
              Element.none
    else
      el
          [ Border.shadow
              { offset = (0, 0)
              , size = 2.0
              , blur = 4.0
              , color = rgba255 237 28 36 0.5
              }
          , Border.rounded 32
          ]
          <| el
              [ width <| px 16
              , height <| px 16
              , Border.width 1
              , Border.rounded 32
              , Border.color <| rgb255 60 60 60
              , Background.color <| rgb255 237 28 36
              , Border.innerGlow (rgba255 255 255 255 0.3) 3.0
              ]
              Element.none


view : Model msg -> (Msg -> msg) -> Element msg
view model toMsg =
    let
        buttonText =
            case model.walletAddress of
                Just walletAddr ->
                    "ウォレットを接続"
                --     let
                --         strAddr =
                --             addressToString walletAddr
                --     in
                --     (String.left 6 strAddr) ++ "..." ++ (String.right 4 strAddr)
                Nothing ->
                    "ウォレットを接続"
    in
    Input.button
        ([ padding 12
        , width fill
        , Font.size 16
        , Border.width 2
        , Border.rounded 8
        , Border.color <| rgb255 167 43 113
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
            (case (model.walletAddress, model.isHover, model.state) of
                (Nothing, False, Default) ->
                    [ Border.shadow
                        { offset = (0.0, 4.0)
                        , size = 0.0
                        , blur = 0.0
                        , color = rgb255 166 43 113
                        }
                    ]
                (Nothing, False, Pressed) ->
                    [ Border.shadow
                        { offset = (0.0, 4.0)
                        , size = 0.0
                        , blur = 0.0
                        , color = rgb255 166 43 113
                        }
                    ]
                (Nothing, True, Pressed) ->
                    [ moveDown 4.0
                    ]
                (Nothing, True, Default) ->
                    [ moveDown 4.0
                    ]
                (Just _, _, _) ->
                    [ moveDown 4.0
                    ]
            ))

        { onPress = Just model.onPress
        , label =
            row
                [ spacing 16 ]
                [ viewLed (model.walletAddress /= Nothing)
                , el [ alpha 0.8 ] <| text buttonText
                ]
        }
