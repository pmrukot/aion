module Msgs exposing (..)

import Dom exposing (Error)
import Navigation exposing (Location)
import Panel.Models exposing (CategoryCreatedData, QuestionCreatedData, RoomCreatedData)
import RemoteData exposing (WebData)
import Phoenix.Socket
import Json.Encode as Encode
import Room.Models exposing (RoomId, RoomsData)
import Toasty
import Toasty.Defaults
import User.Models exposing (CurrentUser)
import Multiselect


type Msg
    = OnLocationChange Location
    | OnFetchRooms (WebData RoomsData)
    | OnFetchCurrentUser (WebData CurrentUser)
    | OnQuestionCreated (WebData QuestionCreatedData)
    | OnCategoryCreated (WebData CategoryCreatedData)
    | OnRoomCreated (WebData RoomCreatedData)
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveUserList Encode.Value
    | SetAnswer String
    | SubmitAnswer
    | ReceiveQuestion Encode.Value
    | FocusResult (Result Error ())
    | KeyDown Int
    | NoOperation
    | ReceiveAnswerFeedback Encode.Value
    | ReceiveUserJoined Encode.Value
    | ToastyMsg (Toasty.Msg Toasty.Defaults.Toast)
    | CreateNewQuestionWithAnswers
    | CreateNewCategory
    | CreateNewRoom
    | UpdateQuestionForm String String
    | UpdateCategoryForm String String
    | UpdateRoomForm String String
    | MultiselectMsg Multiselect.Msg
