module Main exposing (main)

import Element exposing (..)
import Element.Region as Region
import Html exposing (Html)

logo : Element msg
logo =
  el
    [ width <| px 80
    , height <| px 40
    ] <|
    el [ Region.heading 1 ] <|
      text "Very Emoji"


header : Element msg
header =
  row
    [ width fill
    , padding 20
    , spacing 20
    ]
    [ logo
    ]

content : Element msg
content =
  column [ width fill ]
    [
    ]

main : Html msg
main =
  layout [ width fill, height fill] <|
    column [ width fill ]
      [ header
      , content
      ]
