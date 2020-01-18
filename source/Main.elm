module Main exposing (Model, Msg, init, subscriptions, update, view)

import Axis
import Browser
import Color
import Dict
import Html
import Scale
import Scale.Color
import Statistics
import Task
import Time
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Types


main : Program Flag Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flag =
    List ( Int, List ( String, Float ) )


type Model
    = LoadingTimeZone (Dict.Dict String (Dict.Dict Int Float))
    | Model
        { data : Dict.Dict String (Dict.Dict Int Float)
        , timeZone : Time.Zone
        }


init : Flag -> ( Model, Cmd Msg )
init flag =
    ( LoadingTimeZone
        (flag
            |> List.foldl
                (\( time, dataMap ) dict ->
                    dataMap
                        |> List.foldl
                            (\( key, value ) nameAndTimeValueDict ->
                                nameAndTimeValueDict
                                    |> Dict.insert key
                                        (case nameAndTimeValueDict |> Dict.get key of
                                            Just d ->
                                                d |> Dict.insert time value

                                            Nothing ->
                                                Dict.singleton time value
                                        )
                            )
                            dict
                )
                Dict.empty
        )
    , Time.here |> Task.perform ResponseTimeZone
    )


type Msg
    = ResponseTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ResponseTimeZone timeZone, LoadingTimeZone data ) ->
            ( Model
                { data = data
                , timeZone = timeZone
                }
            , Cmd.none
            )

        ( _, _ ) ->
            ( model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


width : Float
width =
    900


height : Float
height =
    450


padding : Float
padding =
    60


colorScale : Dict.Dict String (Dict.Dict Int Float) -> Scale.OrdinalScale String Color.Color
colorScale data =
    data
        |> Dict.keys
        |> Scale.ordinal Scale.Color.category10


color : Dict.Dict String (Dict.Dict Int Float) -> String -> Color.Color
color data name =
    name
        |> Scale.convert (colorScale data)
        |> Maybe.withDefault Color.black


intTimeToString : Time.Zone -> Int -> String
intTimeToString timeZone intTime =
    let
        time =
            Time.millisToPosix intTime

        year =
            Time.toYear timeZone time

        month =
            Time.toMonth timeZone time

        day =
            Time.toDay timeZone time

        hour =
            Time.toHour timeZone time

        minute =
            Time.toMinute timeZone time

        second =
            Time.toSecond timeZone time
    in
    String.fromInt year
        ++ "/"
        ++ monthToString month
        ++ "/"
        ++ String.fromInt day
        ++ " "
        ++ String.fromInt hour
        ++ ":"
        ++ String.fromInt minute
        ++ ":"
        ++ String.fromInt second


monthToString : Time.Month -> String
monthToString month =
    case month of
        Time.Jan ->
            "1"

        Time.Feb ->
            "2"

        Time.Mar ->
            "3"

        Time.Apr ->
            "4"

        Time.May ->
            "5"

        Time.Jun ->
            "6"

        Time.Jul ->
            "7"

        Time.Aug ->
            "8"

        Time.Sep ->
            "9"

        Time.Oct ->
            "10"

        Time.Nov ->
            "11"

        Time.Dec ->
            "12"


view : Model -> Html.Html msg
view model =
    case model of
        LoadingTimeZone data ->
            Html.text "タイムゾーンを取得中……"

        Model record ->
            mainView record


mainView : { data : Dict.Dict String (Dict.Dict Int Float), timeZone : Time.Zone } -> Html.Html msg
mainView { data, timeZone } =
    let
        xScale : Scale.ContinuousScale Float
        xScale =
            data
                |> Dict.foldl (\_ v state -> state ++ Dict.keys v) []
                |> List.map toFloat
                |> Statistics.extent
                |> Maybe.withDefault ( 0, 0 )
                |> Scale.linear ( 0, width - 2 * padding )

        --|> (\scale -> { scale | tickFormat = \timeInt -> intTimeToString timeZone timeInt })
        yScale : Scale.ContinuousScale Float
        yScale =
            ( 0, 1 )
                |> Scale.linear ( height - 2 * padding, 0 )
                |> Scale.nice 4
    in
    Html.div
        []
        [ title
        , TypedSvg.svg
            [ TypedSvg.Attributes.viewBox 0 0 width height ]
            [ TypedSvg.g
                [ TypedSvg.Attributes.transform
                    [ TypedSvg.Types.Translate (padding - 1) (height - padding) ]
                ]
                [ Axis.bottom [ Axis.tickCount 1 ]
                    xScale
                ]
            , TypedSvg.g
                [ TypedSvg.Attributes.transform
                    [ TypedSvg.Types.Translate (padding - 1) padding ]
                ]
                [ Axis.left
                    [ Axis.ticks [ 0 ] ]
                    yScale
                ]
            ]
        ]


title : Html.Html msg
title =
    Html.h1
        []
        [ Html.text "https://us-central1-smart-house-dash.cloudfunctions.net/api に送られてきたデータ" ]
