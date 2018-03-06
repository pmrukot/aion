module Auth.Models exposing (..)

import Forms
import General.Constants exposing (loginFormMsg)


type alias AuthData =
    { loginForm : LoginForm
    , registrationForm : RegistrationForm
    , unauthenticatedView : UnauthenticatedViewToggle
    , formMsg : String
    , token : Maybe Token
    , msg : String
    }


initAuthData : Token -> AuthData
initAuthData token =
    { loginForm = Forms.initForm loginForm
    , registrationForm = Forms.initForm registrationForm
    , unauthenticatedView = LoginView
    , formMsg = loginFormMsg
    , token = token
    , msg = ""
    }


type UnauthenticatedViewToggle
    = LoginView
    | RegisterView


type alias Token =
    String



-- login form section


type alias LoginForm =
    Forms.Form


loginFormFields : List String
loginFormFields =
    [ "email", "password" ]


loginForm : List ( String, List Forms.FieldValidator )
loginForm =
    [ ( "email", [ Forms.validateExistence ] )
    , ( "password", [ Forms.validateExistence ] )
    ]



-- registration form section


type alias RegistrationForm =
    Forms.Form


registrationFormFields : List String
registrationFormFields =
    [ "name", "email", "password" ]


registrationForm : List ( String, List Forms.FieldValidator )
registrationForm =
    [ ( "name", [ Forms.validateExistence ] )
    , ( "email", [ Forms.validateExistence ] )
    , ( "password", [ Forms.validateExistence ] )
    ]


type alias RegistrationResultData =
    { token : Token
    }
