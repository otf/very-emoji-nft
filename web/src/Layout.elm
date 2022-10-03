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
            width <| (fill |> maximum 960)
    in
    row
        ([ containerWidth
         , centerX
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


viewLogo : Element msg
viewLogo =
    link [ Region.heading 1 ]
        { url = "#"
        , label =
            image
                [ height <| px 40 ]
                { src = "images/logo.svg"
                , description = "Very Emoji"
                }
        }


viewHeader : Element msg
viewHeader =
    row
        [ width fill
        , padding 32
        ]
        [ viewLogo
        , blankEl "CONNECT WALLET" (px 200) (px 40) [ alignRight ]
        ]


viewContent : Element msg
viewContent =
    container
        []
        [ blankEl "GALLERY" (px 960) (px 1920) []
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
        [ width fill
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
