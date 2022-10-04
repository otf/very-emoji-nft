module Layout exposing (viewLayout)

import ColorSchemes
import Element exposing (..)
import Element.Region as Region
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)


container : List (Attribute msg) -> List (Element msg) -> Element msg
container attrs elems =
    let
        containerWidth =
            width <| maximum 960 <| fill
    in
    row
        ([ containerWidth
         , centerX
         , padding 32
         ]
            ++ attrs
        )
        elems


blankEl txt w h attrs =
    let
        blankColor =
            rgb255 180 180 180

        borderColor =
            rgb255 0 0 0
    in
    el
        ([ width <| w
         , height <| h
         , color blankColor
         , Font.size 8
         , Border.color borderColor
         , Border.width 3
         , Border.dotted
         ]
            ++ attrs
        )
    <|
        el [ centerX, centerY ] <|
            text txt


viewLogo : List (Attribute msg) -> Element msg
viewLogo attrs =
    link [ Region.heading 1 ]
        { url = "#"
        , label =
            image
                attrs
                { src = "images/logo.svg"
                , description = "Very Emoji"
                }
        }


viewHeader : Element msg
viewHeader =
    wrappedRow
        [ width fill
        , padding 32
        , spacingXY 64 32
        ]
        [ viewLogo [ width (fillPortion 1) ]
        , el [ width (fillPortion 6), height (px 0) ] Element.none
        , blankEl "CONNECT WALLET" (fillPortion 1 |> maximum 480) shrink [ alignRight, padding 8 ]
        ]


viewContent : Element msg
viewContent =
    container
        []
        [ blankEl "GALLERY" fill (px 1920) []
        ]


viewJumbotron : Element msg
viewJumbotron =
    row
        [ width fill ]
        [ blankEl "Jumbotron" fill (px 320) [ centerX ]
        ]


viewFooter : Element msg
viewFooter =
    row
        [ width fill
        ]
        [ blankEl "T" (px 32) (px 32) [ centerX ]
        ]


viewLayout : Html msg
viewLayout =
    layout
        [ width (fill |> minimum 360)
        , height fill
        ]
    <|
        column
            [ width fill
            , ColorSchemes.backgroundColor
            ]
            [ viewHeader
            , viewJumbotron
            , viewContent
            , viewFooter
            ]
