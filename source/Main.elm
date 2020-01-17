module Main exposing (Model, Msg, init, subscriptions, update, view)

import Axis
import Browser
import Color exposing (Color)
import Html
import Path exposing (Path)
import Scale exposing (ContinuousScale, OrdinalScale)
import Scale.Color
import Shape
import Statistics
import Svg
import Svg.Attributes
import Time
import TypedSvg exposing (g, svg, text_)
import TypedSvg.Attributes exposing (class, dy, fill, fontFamily, stroke, textAnchor, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (fontSize, height, strokeWidth, x, y)
import TypedSvg.Core exposing (Svg, text)
import TypedSvg.Types exposing (AnchorAlignment(..), Fill(..), Transform(..), em)


main : Program Flag Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flag =
    List ( String, List ( Int, Float ) )


type Model
    = Model
        { data : List ( String, List ( Time.Posix, Float ) )
        }


init : Flag -> ( Model, Cmd Msg )
init flags =
    ( Model
        { data = flags |> List.map (Tuple.mapSecond (List.map (Tuple.mapFirst Time.millisToPosix)))
        }
    , Cmd.none
    )


type alias Msg =
    Never


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


w : Float
w =
    900


h : Float
h =
    450


padding : Float
padding =
    60


series data =
    List.map
        (\( label, d ) ->
            { label = label
            , accessor = d
            }
        )


accessors : List (CrimeRate -> Int)
accessors =
    List.map .accessor series


values : CrimeRate -> List Float
values i =
    List.map (\a -> toFloat <| a i) accessors


colorScale : OrdinalScale String Color
colorScale =
    List.map .label series
        |> Scale.ordinal Scale.Color.category10


color : String -> Color
color =
    Scale.convert colorScale >> Maybe.withDefault Color.black


view : Model -> Svg msg
view (Model { data }) =
    let
        last =
            -1

        first =
            1

        xScale : ContinuousScale Float
        xScale =
            data
                |> List.map (.year >> toFloat)
                |> Statistics.extent
                |> Maybe.withDefault ( 1900, 1901 )
                |> Scale.linear ( 0, w - 2 * padding )

        yScale : ContinuousScale Float
        yScale =
            data
                |> List.map (values >> List.maximum >> Maybe.withDefault 0)
                |> List.maximum
                |> Maybe.withDefault 0
                |> (\b -> ( 0, b ))
                |> Scale.linear ( h - 2 * padding, 0 )
                |> Scale.nice 4

        lineGenerator : ( Int, Int ) -> Maybe ( Float, Float )
        lineGenerator ( x, y ) =
            Just ( Scale.convert xScale (toFloat x), Scale.convert yScale (toFloat y) )

        line : (( Time.Posix, Float ) -> ( Time.Posix, Float )) -> Path
        line accessor =
            accessor data
                |> List.map (\( time, value ) -> ( Time.posixToMillis time, value ))
                |> List.map lineGenerator
                |> Shape.line Shape.monotoneInXCurve
    in
    svg [ viewBox 0 0 w h ]
        [ g [ transform [ Translate (padding - 1) (h - padding) ] ]
            [ Axis.bottom [ Axis.tickCount 10 ] xScale ]
        , g [ transform [ Translate (padding - 1) padding ] ]
            [ Axis.left [ Axis.ticks (values first) ] yScale
            , text_ [ fontFamily [ "sans-serif" ], fontSize 10, x 5, y 5 ] [ text "Occurences" ]
            ]
        , g [ transform [ Translate padding padding ], class [ "series" ] ]
            (List.map
                (\{ accessor, label } ->
                    Path.element (line accessor)
                        [ stroke (color label)
                        , strokeWidth 3
                        , fill FillNone
                        ]
                )
                (series data)
            )
        , g [ fontFamily [ "sans-serif" ], fontSize 10 ]
            (List.map
                (\{ accessor, label } ->
                    g
                        [ transform
                            [ Translate (w - padding + 10) (padding + Scale.convert yScale (toFloat (accessor last)))
                            ]
                        ]
                        [ text_ [ fill (Fill (color label)) ] [ text label ] ]
                )
                (series data)
            )
        , g [ transform [ Translate (w - padding) (padding + 20) ] ]
            [ text_ [ fontFamily [ "sans-serif" ], fontSize 20, textAnchor AnchorEnd ] [ text "Violent Crime in the US" ]
            , text_ [ fontFamily [ "sans-serif" ], fontSize 10, textAnchor AnchorEnd, dy (em 1) ] [ text "Source: fbi.gov" ]
            ]
        ]
