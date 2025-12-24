;Settings
#NoEnv
SetWorkingDir %A_ScriptDir% 
CoordMode, Mouse, Screen 
CoordMode, Pixel, Screen 

;Event - Counter the mouse movement better
SendMode Event 
SetDefaultMouseSpeed, 5 

F1:: 
    Loop ; runs until user stops with F2
    {
        ; search raid start screen to start the programm
        Loop 
        {
            ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png
            if (ErrorLevel = 0) 
                break ; Search is finished
            Sleep, 2000 
        }

        ; Zoomes out
        Send, {WheelDown 5}
        Sleep, 400 
        Send, 1
        Sleep, 400

        ; Move the mouse to the right position and klick one time
        MouseMove, 12, 474
        Sleep, 200 

        Click, Down
        Sleep, 50 
        Click, Up
        Sleep, 500

        ; Click the button to use the attack in raid
        Sleep, 500
        Send, {c Down}
        Sleep, 50
        Send, {c Up}
        Sleep, 9000

        ; Click to skip rewards fast
        Sleep, 500
        Click
        Sleep, 500
        Click
        Sleep, 1500
        ; search the image.png (Retry button)
        ImageGefunden := false 
        Loop, 3 
        {
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 image.png
            if (ErrorLevel = 0) 
            {
                MouseMove, %FoundX%, %FoundY%
                Sleep, 100
                ; Clicks more times to go safe
                Loop, 2 {
                    Click
                    Sleep, 100
                }
                ImageGefunden := true
                break ; Search 3 times for the image after that waiting for the new run
            }
            Sleep, 1000 
        }

        ToolTip, Run finished, waiting for next round
            Sleep, 9000
        ToolTip
    }
return

F2::ExitApp