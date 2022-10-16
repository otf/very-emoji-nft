module Components.MintButton exposing
    ( view
    , init
    , update
    , Msg
    , Model
    )

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
import BigInt exposing (BigInt)


type ButtonState
    = Default
    | Pressed


type alias Model msg =
    { state : ButtonState
    , isHover : Bool
    , onPress : BigInt -> msg
    , walletAddress : Maybe Address
    , isMinted : Bool
    , isMinting : Bool
    , tokenId : BigInt
    }


type Msg
    = OnMouseDown
    | OnMouseUp
    | OnMouseEnter
    | OnMouseLeave


init : (BigInt -> msg) -> Maybe Address -> List BigInt -> List BigInt -> BigInt -> Model msg
init onPress walletAddress mintingTokenIds mintedTokenIds tokenId =
    { state = Default
    , isHover = False
    , onPress = onPress
    , walletAddress = walletAddress
    , isMinting =
        mintingTokenIds 
        |> List.any ((==) tokenId)
    , isMinted =
        mintedTokenIds 
        |> List.any ((==) tokenId)
    , tokenId = tokenId
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


view : Model msg -> Element msg
view model =
    let
        canMint =
            model.walletAddress /= Nothing && not model.isMinted
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
        { onPress = if canMint && not model.isMinting then Just (model.onPress model.tokenId) else Nothing
        , label =
            if model.isMinting then
                image [] { src = "images/rolling.gif", description = "minting..." }
            else
                text "ミント"
        }
