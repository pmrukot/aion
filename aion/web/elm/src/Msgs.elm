module Msgs exposing (..)

import Bootstrap.Navbar as Navbar
import Dom exposing (Error)
import Navigation exposing (Location)
import Panel.Models exposing (CategoriesData, CategoryCreatedData, QuestionCreatedData)
import RemoteData exposing (WebData)
import Phoenix.Socket
import Json.Encode as Encode
import Room.Models exposing (RoomId, RoomsData)
import Toasty
import Toasty.Defaults
import User.Models exposing (CurrentUser)


type Msg
    = OnLocationChange Location
    | OnFetchRooms (WebData RoomsData)
    | OnFetchCategories (WebData CategoriesData)
    | OnFetchCurrentUser (WebData CurrentUser)
    | OnQuestionCreated (WebData QuestionCreatedData)
    | OnCategoryCreated (WebData CategoryCreatedData)
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
    | UpdateQuestionForm String String
    | UpdateCategoryForm String String
    | NavbarMsg Navbar.State
    | LeaveRoom RoomId
