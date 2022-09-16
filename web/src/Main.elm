module Main exposing (main)

import Element exposing (..)
import Element.Region as Region
import Html exposing (Html)

main : Html msg
main =
  layout [] <|
    row 
      [ height fill
      , width fill ]
      [ el 
          [ centerX
          , centerY
          , Region.heading 1
          ]
          <|
          text "Very Emoji" 
      ]
      
