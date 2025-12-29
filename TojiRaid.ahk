;===========================================
; CONFIGURATION
;===========================================
#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SendMode Event
SetDefaultMouseSpeed, 0

;--- Default Method ---
ActiveMethod := 1

;===========================================
; CREATE GUI
;===========================================
Gui, +AlwaysOnTop
Gui, Color, 0x1a1a1a
Gui, Font, s10 cWhite, Segoe UI

Gui, Add, Text, x20 y15 w300 Center, === RAID MACRO CONTROLLER ===

Gui, Add, GroupBox, x20 y50 w300 h120, Method Selection

; Unique variables: vMethodRadio1 and vMethodRadio2
Gui, Add, Radio, x40 y75 w260 vMethodRadio1 gMethodSwitch Checked, Method 1: (All supported | Slot 1 move only)
Gui, Add, Radio, x40 y105 w260 vMethodRadio2 gMethodSwitch, Method 2: (All supported | Both Slot moves)

; vMethodText allows the GUI to update the display dynamically
Gui, Add, Text, x40 y140 w260 cYellow vMethodText, Active Method: 1

Gui, Add, GroupBox, x20 y180 w300 h100, Controls
Gui, Add, Text, x40 y205 w260, F1 = Start Macro
Gui, Add, Text, x40 y225 w260, F2 = Stop Macro (Reload)
Gui, Add, Text, x40 y245 w260, ESC = Close GUI

Gui, Add, GroupBox, x20 y290 w300 h80, Status
Gui, Add, Text, x40 y315 w260 vStatusText cLime, Ready - Press F1 to Start

Gui, Show, w340 h390, Raid Macro v2.0
return

;===========================================
; METHOD SWITCH VIA GUI
;===========================================
MethodSwitch:
    Gui, Submit, NoHide
    if (MethodRadio1) {
        ActiveMethod := 1
    } else {
        ActiveMethod := 2
    }
    GuiControl,, StatusText, Method %ActiveMethod% activated
    GuiControl,, MethodText, Active Method: %ActiveMethod%
return

;===========================================
; MAIN LOOP - F1 TO START
;===========================================
F1::
    GuiControl,, StatusText, Macro running... (Method %ActiveMethod%)
    Loop
    {
        ToolTip, Waiting for "start.png"...

        ; Look for the start image
        Loop
        {
            ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png
            if (ErrorLevel = 0)
                break 
            Sleep, 2000
        }

        ToolTip, Found start - Executing Method %ActiveMethod%
        GuiControl,, StatusText, Image found - Executing...

        ; Move mouse to screen center
        MouseMove, A_ScreenWidth/2, A_ScreenHeight/2, 3
        Sleep, 100

        ; Zoom and Skill
        Sleep, 400
        Send, {WheelDown 5}
        Sleep, 400
        Send, 1
        Sleep, 400

        ; Move mouse to click position
        MouseMove, 747, 413, 5
        Sleep, 200
        Click, Down
        Sleep, 50
        Click, Up
        Sleep, 500

        ; === ATTACK SEQUENCE ===
        if (ActiveMethod = 1)
        {
            Sleep, 800
            Send, {c Down}
            Sleep, 800
            Send, {c Up}
            Sleep, 7000
        }
        else if (ActiveMethod = 2)
        {
            Sleep, 800
            Send, {c Down}
            Sleep, 800
            Send, {c Up}
            Sleep, 9000

            Send, 2

            Sleep, 800
            Send, {c Down}
            Sleep, 800
            Send, {c Up}
            Sleep, 9000
        }

        ; Skip rewards - Fixed calculation (A_ScreenHeight - 20)
        MouseMove, 10, A_ScreenHeight - 20, 5
        Loop, 4 {
            Click
            Sleep, 500
        }

        ; Search for Retry Button
        GuiControl,, StatusText, Searching for retry button...
            imageList := ["image1920x1080.png", "image1366x768.png", "image1760x990.png", "image2560x1440.png"] 
        ImageFound := false

        Loop, 4 
        {
            for index, fileName in imageList 
            {
                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *60 %fileName%
                if (ErrorLevel = 0)
                {
                    MouseMove, %FoundX%, %FoundY%, 5
                    Sleep, 100
                    Click, 2 ; Double click for reliability
                    ImageFound := true
                    break 2 
                }
            }
            Sleep, 1000 
        }

        GuiControl,, StatusText, Run completed - Waiting 15s...
        Sleep, 15000
    }
return

;===========================================
; HOTKEYS FOR QUICK SWITCH
;===========================================
F3::
    ActiveMethod := 1
    GuiControl,, MethodRadio1, 1
    GuiControl,, MethodRadio2, 0
    GuiControl,, StatusText, Method 1 activated
    GuiControl,, MethodText, Active Method: 1
return

F4::
    ActiveMethod := 2
    GuiControl,, MethodRadio1, 0
    GuiControl,, MethodRadio2, 1
    GuiControl,, StatusText, Method 2 activated
    GuiControl,, MethodText, Active Method: 2
return

;===========================================
; EXIT / STOP
;===========================================
F2::
    GuiControl,, StatusText, Macro stopped!
    Reload ; Reloads script to stop the loop immediately
return

GuiClose:
ESC::
ExitApp
return