module Room.View exposing (..)

import General.Models exposing (Model)
import Html exposing (Html, a, button, div, form, input, li, text, ul)
import Html.Attributes exposing (href)
import Html.Events exposing (onInput)
import Room.Utils exposing (getRoomList, getRoomNameById)
import Msgs exposing (Msg(SetAnswer))
import RemoteData exposing (WebData)
import Room.Models exposing (RoomId, RoomsData, UserInRoomRecord)


roomListView : Model -> Html Msg
roomListView model =
    div []
        [ div [] [ text "Rooms:" ]
        , listRooms model.rooms
        ]


roomView : Model -> RoomId -> Html Msg
roomView model roomId =
    let
        roomName =
            getRoomNameById model roomId
    in
        div []
            [ text roomName
            , displayScores model
            ]


displayAnswerInput : Model -> Html Msg
displayAnswerInput model =
    form []
        [ input [ onInput SetAnswer ]
            []
        , button []
            [ text "Submit"
            ]
        ]


displayScores : Model -> Html Msg
displayScores model =
    ul [] (List.map displaySingleScore model.usersInChannel)


displaySingleScore : UserInRoomRecord -> Html Msg
displaySingleScore userRecord =
    li [] [ text (userRecord.name ++ ": " ++ (toString userRecord.score)) ]


listRooms : WebData RoomsData -> Html Msg
listRooms response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success roomsData ->
            ul []
                (List.map (\room -> li [] [ a [ href ("#rooms/" ++ (toString room.id)) ] [ text room.name ] ]) roomsData.data)

        RemoteData.Failure error ->
            text (toString error)