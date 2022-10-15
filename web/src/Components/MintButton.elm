module Components.MintButton exposing (viewMintButton, init, update, Msg, Model)

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
import Html.Attributes as RawAttrs

type Model
    = Normal
    | Pressed

type Msg
    = OnMouseDown
    | OnMouseUp


init : Model
init =
    Normal

update : Model -> Msg -> (Model, Cmd Msg)
update model msg =
    case msg of
        OnMouseDown ->
            (Pressed, Cmd.none)
        OnMouseUp ->
            (Normal, Cmd.none)


viewMintButton : msg -> Maybe Address -> Bool -> Bool -> Element msg
viewMintButton msg walletAddress isMinted isLoading =
    let
        canMint =
            walletAddress /= Nothing && not isMinted
    in
    Input.button
        [ padding 8
        , width fill
        , ColorSchemes.mintButtonBackgroundColor
        , ColorSchemes.mintButtonForegroundColor
        , Font.center
        , Font.size 24
        , Font.bold
        , Font.color <| rgb255 0 0 0
        , Font.family
            [ Font.external
                { name = "DotGothic16"
                , url = "https://fonts.googleapis.com/css2?family=DotGothic16"
                }
            , Font.sansSerif
            ]
        , ColorSchemes.mintButtonForegroundColor
        , Border.width 2
        --, ColorSchemes.mintButtonBorderColor
        , htmlAttribute <| RawAttrs.style "outline" "2px solid #000000"
        , htmlAttribute <| RawAttrs.style "border-color" "#E6E6E6 #808080 #808080 #E6E6E6"
        , alpha (if canMint then 1.0 else 0.5)
        , focused []
        -- , Events.onMouseDown <| toMsg OnMouseDown
        -- , Events.onMouseUp <| toMsg OnMouseUp
        ]
        { onPress = if canMint && not isLoading then Just msg else Nothing
        , label =
            if isLoading then
                image [] { src = "images/rolling.gif", description = "minting..." }
            else
                text "ミント"
        }
