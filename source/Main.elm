module Main exposing (Model, Msg, init, subscriptions, update, view)

import Browser
import Html
import Time


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
        { data : List ( String, List ( Time., Float ) )
        }


init : Flag -> ( Model, Cmd Msg )
init flags =
    ( Model
        { key = flags |> Lisr.map (Tuple.mapSecond (List.map (Tuple.mapFirst Time.))) }
    , Cmd.none
    )


type Msg
    = Msg1
    | Msg2


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg1 ->
            ( model, Cmd.none )

        Msg2 ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ text "New Element" ]
