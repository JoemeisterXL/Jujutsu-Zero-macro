;Settings
#NoEnv
SetWorkingDir %A_ScriptDir% 
CoordMode, Mouse, Screen 
CoordMode, Pixel, Screen 

RefBreite := 2560
RefHoehe := 1600

; Event - Counter the mouse movement better
SendMode Event 
SetDefaultMouseSpeed, 5 

; Funktion zur Umrechnung der Koordinaten
RelX(x) {
    global RefBreite
    return (x / RefBreite) * A_ScreenWidth
}

RelY(y) {
    global RefHoehe
    return (y / RefHoehe) * A_ScreenHeight
}

F1:: 
    Loop ; runs until user stops with F2
    {

        Loop 
        {

            ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png
            if (ErrorLevel = 0) 
                break 
            Sleep, 2000 
        }

        Send, {WheelDown 5}
        Sleep, 400 
        Send, 1
        Sleep, 400

        MouseMove, RelX(12), RelY(474)
        Sleep, 200 

        Click, Down
        Sleep, 50 
        Click, Up
        Sleep, 500

        Sleep, 500
        Send, {c Down}
        Sleep, 50
        Send, {c Up}
        Sleep, 9000

        Sleep, 500
        Click
        Sleep, 500
        Click
        Sleep, 2000

        ImageGefunden := false 
        Loop, 4 
        {
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 image.png
            if (ErrorLevel = 0) 
            {

                MouseMove, %FoundX%, %FoundY%
                Sleep, 100
                Loop, 2 {
                    Click
                    Sleep, 100
                }
                ImageGefunden := true
                break 
            }
            Sleep, 1000 
        }

        MouseMove, RelX(800), RelY(100)
        Sleep, 100
        Loop, 3 
        {
            Click
            Sleep, 200 
        }

        ToolTip, Run finished, waiting for next round
            Sleep, 9000
        ToolTip
    }
return

F2::ExitApp