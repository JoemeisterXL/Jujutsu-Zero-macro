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

Gui, Add, Radio, x40 y75 w260 vMethod1 gMethodSwitch Checked, Method 1: No Rotation (Fuga + Meteor Support)
Gui, Add, Radio, x40 y105 w260 vMethod2 gMethodSwitch, Method 2: Rotation Only (Hollow Purple + Fuga + Disaster tides Support)

Gui, Add, Text, x40 y140 w260 cYellow, Active Method: 1

Gui, Add, GroupBox, x20 y180 w300 h100, Controls

Gui, Add, Text, x40 y205 w260, F1 = Start Macro
Gui, Add, Text, x40 y225 w260, F2 = Stop Macro
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
    if (Method1)
    {
        ActiveMethod := 1
        GuiControl,, StatusText, Method 1 activated (No Rotation)
        GuiControl, Text, Text6, Active Method: 1
    }
    else if (Method2)
    {
        ActiveMethod := 2
        GuiControl,, StatusText, Method 2 activated (Rotation Only)
        GuiControl, Text, Text6, Active Method: 2
    }
return

;===========================================
; MAIN LOOP - F1 TO START
;===========================================
F1::
    GuiControl,, StatusText, Macro running... (Method %ActiveMethod%)
    Loop
    {
        ToolTip, Run started (Method %ActiveMethod%)

        Loop
        {
            ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png
            if (ErrorLevel = 0)
                break 
            Sleep, 2000
        }

        ToolTip, Found first image - Method %ActiveMethod%
        GuiControl,, StatusText, Image found - Executing Method %ActiveMethod%

        ; === METHOD LOGIC ===
        if (ActiveMethod = 1)
        {
            ; METHOD 1: No Rotation - Fuga + Meteor Support
            ; Move mouse to screen center - REALISTIC
            MouseMove, A_ScreenWidth/2, A_ScreenHeight/2, 3
            Sleep, 100

            ; Zoom and Skill
            Sleep, 400
            Send, {WheelDown 5}
            Sleep, 400
            Send, 1
            Sleep, 400

            ; Move mouse to position (ONLY for Method 1) - REALISTIC
            MouseMove, 12, 474, 5
            Sleep, 200
            Click, Down
            Sleep, 50
            Click, Up
            Sleep, 500
        }
        else if (ActiveMethod = 2)
        {
            ; METHOD 2: Rotation Only - Hollow Purple + Fuga Support
            ; Move mouse to screen center - REALISTIC
            MouseMove, A_ScreenWidth/2, A_ScreenHeight/2, 3
            Sleep, 100

            ; Press right mouse button
            Click, Right, Down
            Sleep, 100

            ; Rotate left - REALISTIC
            MouseMove, -5.8, 0, 3, R
            Sleep, 100

            ; Release right mouse button
            Click, Right, Up
            Sleep, 100

            Send, {Control}
            Sleep, 500
            Send, {Control}
            Sleep, 2000

            ; Click bottom left corner
            Send, 1
        }

        ; === COMMON SEQUENCE ===
        GuiControl,, StatusText, Executing attack...

        ; Attack (Key C)
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

        ; Skip rewards - REALISTIC
        MouseMove, 10, A_ScreenHeight 20, 5
        Sleep, 100
        Click
        Sleep, 500
        Click
        Sleep, 500
        Click
        Sleep, 500
        Click

        ; Search for Retry Button
        GuiControl,, StatusText, Searching for retry button...
            ToolTip, Searching for retry button
            imageList := ["image1920x1080.png", "image1366x768.png", "image1760x990.png", "image2560x1440.png", "image.png", "Image.png"] 
        ImageFound := false

        Loop, 4 
        {
            ToolTip, Search round %A_Index% of 4
            for index, fileName in imageList 
            {
                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *60 %fileName%
                if (ErrorLevel = 0)
                {
                    MouseMove, %FoundX%, %FoundY%, 5
                    Sleep, 100
                    Loop, 2 {
                        Click
                        Sleep, 100
                    }
                    ImageFound := true
                    break 2 
                }
            }
            if (ImageFound)
                break
            Sleep, 1000 
        }

        GuiControl,, StatusText, Run completed - Restarting...
        ToolTip, Run finished (Method %ActiveMethod%)
        Sleep, 15000
        ToolTip
    }
return

;===========================================
; HOTKEYS
;===========================================
F3::
    ActiveMethod := 1
    GuiControl,, Method1, 1
    GuiControl,, Method2, 0
    GuiControl,, StatusText, Method 1 activated (No Rotation)
    GuiControl, Text, Text6, Active Method: 1
    ToolTip, Method 1 activated
    Sleep, 2000
    ToolTip
return

F4::
    ActiveMethod := 2
    GuiControl,, Method1, 0
    GuiControl,, Method2, 1
    GuiControl,, StatusText, Method 2 activated (Rotation Only)
    GuiControl, Text, Text6, Active Method: 2
    ToolTip, Method 2 activated
    Sleep, 2000
    ToolTip
return

;===========================================
; EXIT
;===========================================
F2::
    GuiControl,, StatusText, Macro stopped!
    Sleep, 1000
ExitApp
return

GuiClose:
ESC::
ExitApp
return