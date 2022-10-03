module Layout exposing (viewLayout)

import Element exposing (..)
import Element.Background exposing (color)
import Element.Border as Border
import Html exposing (Html)

import ColorSchemes


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
         , Border.color borderColor
         , Border.width 3
         , Border.dotted
         ]
            ++ attrs
        )
    <|
        el [ centerX, centerY ] 
            <| text txt


viewHeader : Element msg
viewHeader =
    row [ width fill ]
        [ blankEl "LOGO" (px 200) (px 60) []
        , blankEl "CONNECT WALLET" (px 200) (px 60) [ alignRight ]
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
