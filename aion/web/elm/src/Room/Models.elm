module Room.Models exposing (..)

import Navigation exposing (Location)


type alias RoomData =
    { location : Location
    , roomState : RoomState
    , eventLog : EventLog
    , progressBar : ProgressBar
    , userList : UserList
    , userGameData : UserGameData
    , currentQuestion : CurrentQuestion
    , roomId : Int
    }


initRoomData : RoomData
initRoomData =
    { roomState = QuestionBreak
    , eventLog = initialLog
    , progressBar = initialProgressBar
    , userList = []
    , userGameData = { currentAnswer = "" }
    , currentQuestion =
        { content = ""
        , image_name = ""
        }
    , roomId = 0
    }


type RoomState
    = QuestionDisplayed
    | QuestionBreak


type alias UserRecord =
    { name : String
    , score : Int
    , questionsAsked : Int
    }



-- ^ to underscore


type alias UserList =
    List UserRecord


type alias UserListMessage =
    { users : UserList }


type alias UserGameData =
    { currentAnswer : String }


type alias CurrentQuestion =
    { content : String
    , image_name : ImageName
    }


type alias UserJoinedInfo =
    { user : String
    }


type alias AnswerFeedback =
    { feedback : String }


type alias ImageName =
    String


type alias Answer =
    String


type alias EventLog =
    List Event


type Event
    = MkUserJoinedLog UserJoined
    | MkUserLeftLog UserLeft
    | MkQuestionSummaryLog QuestionSummary


type alias UserJoined =
    { currentPlayer : String
    , newPlayer : String
    }


type alias UserLeft =
    { user : String
    }


type alias QuestionSummary =
    { winner : String
    , answers : List String
    }


asLogIn : EventLog -> Event -> EventLog
asLogIn eventLog event =
    event :: eventLog


initialLog : EventLog
initialLog =
    []


type alias ProgressBar =
    { start : Float
    , progress : Float
    , running : ProgressBarState
    }


initialProgressBar : ProgressBar
initialProgressBar =
    { start = 0.0
    , progress = 0.0
    , running = Uninitialized
    }


type ProgressBarState
    = Running
    | Uninitialized
    | Stopped


type alias Progress =
    Float


withProgress : Progress -> ProgressBar -> ProgressBar
withProgress progress bar =
    { bar | progress = progress }


withRunning : ProgressBarState -> ProgressBar -> ProgressBar
withRunning running bar =
    { bar | running = running }


withStart : Float -> ProgressBar -> ProgressBar
withStart start bar =
    { bar | start = start }


asEventLogIn : Model -> EventLog -> Model
asEventLogIn model eventLog =
    { model | eventLog = eventLog }


asProgressBarIn : Model -> ProgressBar -> Model
asProgressBarIn model bar =
    { model | progressBar = bar }
