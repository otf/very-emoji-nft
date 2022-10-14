module Layout exposing (viewLayout, Layout)

import ColorSchemes
import Config
import Element exposing (..)
import Element.Region as Region
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)


container : List (Attribute msg) -> Element msg -> Element msg
container attrs elem =
    let
        containerWidth =
            width <| maximum 960 <| fill
    in
    el
        ([ containerWidth
         , centerX
         , padding 32
         ]
            ++ attrs
        )
        elem


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


viewLogo : List (Attribute msg) -> Bool -> Element msg
viewLogo attrs enabled =
    link (if enabled then [Region.heading 1] else [ ])
        { url = "#"
        , label =
            image
                attrs
                { src = "images/logo.svg"
                , description = "Very Emoji"
                }
        }


viewNotificationBar : Maybe String -> Element msg
viewNotificationBar message =
    case message of
        Just strMessage ->
          el
             [ width fill
             , padding 16
             , centerX
             , color (rgb255 250 250 250)
             , Font.color (rgb255 115 115 115)
             , Font.bold
             , Font.size 16
             , Border.rounded 8
             , Border.color (rgb255 115 115 115)
             , Border.width 3
             ]
             <| paragraph [] [text strMessage]
        Nothing ->
              Element.none

viewHeader : (Element msg -> Element msg) -> Element msg -> Maybe String -> Bool -> Element msg
viewHeader wrapContainer connectWalletButton message enabled =
    column
        [ width fill
        ]
        ([ wrappedRow
              [ width fill
              , padding 32
              , spacingXY 64 32
              , ColorSchemes.headerBackgroundColor
              , transparent <| not enabled
              ]
              [ viewLogo [ width (fillPortion 1) ] enabled
              , el [ width (fillPortion 6), height (px 0) ] Element.none
              , el
                  [ width (fillPortion 1 |> maximum 480)
                  , height shrink
                  , alignRight
                  ]
                  connectWalletButton
              ]
        ] ++ (if enabled then [wrapContainer <| viewNotificationBar message] else []))


viewSocialLink : String -> String -> String -> Element msg
viewSocialLink url imgSrc alt =
    newTabLink
       [ centerX
       ]
       { url = url
       , label =
           image
             [ width (px 40)
             ]
             { src = imgSrc
             , description = alt
             }
       }



viewFooter : Element msg
viewFooter =
    row
        [ width fill
        , paddingEach
            { top = 0
            , bottom = 128
            , left = 0
            , right = 0
            }
        , spacing 32
        ]
        [ viewSocialLink "https://twitter.com/sizuku_eth" "images/twitter.svg" "twitter/@sizuku_eth"
        , viewSocialLink Config.linkForEtherscan "images/etherscan.svg" "etherscan"
        ]


type alias Layout msg =
    { connectWalletButton : Element msg
    , jumbotron : (Element msg -> Element msg) -> Element msg
    , gallery : (Element msg -> Element msg) -> Element msg
    , message : Maybe String
    }

viewLayout : Layout msg -> Html msg
viewLayout { connectWalletButton, jumbotron, gallery, message } =
    let
        header = viewHeader (container []) connectWalletButton message
    in
    layout
        [ width (fill |> minimum 360)
        , height fill
        , inFront <| header True
        ]
    <|
        column
            [ width fill
            , ColorSchemes.backgroundColor
            ]
            [ header False
            , jumbotron (container [])
            , gallery (container [])
            , viewFooter
            ]
