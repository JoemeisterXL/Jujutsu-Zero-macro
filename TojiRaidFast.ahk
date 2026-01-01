;===========================================
; CONFIGURATION
;===========================================
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SendMode Event
SetDefaultMouseSpeed, 0

; Basis-Auflösung, auf der deine Koordinaten basieren
BaseW := 1920
BaseH := 1080

;--- Default Method ---
ActiveMethod := 1

;===========================================
; CREATE GUI
;===========================================
Gui, +AlwaysOnTop
Gui, Color, 0x1a1a1a
Gui, Font, s10 cWhite, Segoe UI

Gui, Add, Text, x20 y15 w300 Center, === RAID MACRO CONTROLLER ===

Gui, Add, GroupBox, x20 y50 w300 h150, Method Selection
Gui, Add, Radio, x40 y75 w260 vMethodRadio1 gMethodSwitch Checked, Method 1: All supported | Slot 1 move
Gui, Add, Radio, x40 y105 w260 vMethodRadio2 gMethodSwitch, Method 2: All supported | Both Slots
Gui, Add, Radio, x40 y135 w260 vMethodRadio3 gMethodSwitch, Method 3: Festering/Spear

Gui, Font, s9 Bold cYellow
Gui, Add, Text, x40 y175 w260 vMethodText, Active Method: 1
Gui, Font, s10 norm cWhite

Gui, Add, GroupBox, x20 y210 w300 h110, Controls
Gui, Add, Text, x40 y235 w260, F1 = Start Macro
Gui, Add, Text, x40 y255 w260, F2 = Stop / Reload
Gui, Add, Text, x40 y275 w260, F3/F4/F5 = Quick Switch Method
Gui, Add, Text, x40 y295 w260, ESC = Close GUI

Gui, Add, GroupBox, x20 y330 w300 h60, Status
Gui, Add, Text, x40 y355 w260 vStatusText cLime, Ready - Press F1 to Start

Gui, Show, w340 h410, Raid Macro v2.5
return

MethodSwitch:
    Gui, Submit, NoHide
    if (MethodRadio1)
        ActiveMethod := 1
    else if (MethodRadio2)
        ActiveMethod := 2
    else if (MethodRadio3)
        ActiveMethod := 3
    GuiControl,, StatusText, Method %ActiveMethod% activated
    GuiControl,, MethodText, Active Method: %ActiveMethod%
return

;===========================================
; MAIN LOOP - F1 TO START
;===========================================
F1::
    ; Verhältnis berechnen (Ratio)
    RatioX := A_ScreenWidth / BaseW
    RatioY := A_ScreenHeight / BaseH

    ; Berechnete Koordinaten
    CombatX := 747 * RatioX
    CombatY := 413 * RatioY
    RewardX := 10 * RatioX
    RewardY := 240 * RatioY

    GuiControl,, StatusText, Macro running... (Method %ActiveMethod%)
    Loop
    {
        ToolTip, Waiting for "start.png"...
            Loop
        {
            ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png
            if (ErrorLevel = 0)
                break 
            Sleep, 200
        }

        ToolTip, Found start - Executing Method %ActiveMethod%
        GuiControl,, StatusText, Image found - Executing...

        ; Maus zur Mitte (dynamisch)
        MouseMove, A_ScreenWidth/2, A_ScreenHeight/2, 3
        Sleep, 100

        ; Zoom und Skill
        Sleep, 200
        Send, {WheelDown 5}
        Sleep, 200
        Send, 1
        Sleep, 200

        ; Bewegung zur Kampfposition (berechnet)
        MouseMove, %CombatX%, %CombatY%, 5

        ; === ATTACK SEQUENCE ===
        if (ActiveMethod = 1)
        {
            Sleep, 400
            Send, {c Down}
            Sleep, 400
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
            Sleep, 7000
        }
        else if (ActiveMethod = 3)
        {
            Send, {MButton}
            Sleep, 500
            Loop, 2 {
                Send, {e Down}
                Sleep, 200
                Send, {e Up}
                Sleep, 400
            }
            Send, 2
            Sleep, 100
            Send, 1
            Loop, 2 {
                Sleep, 700
                Send, {r Down}
                Sleep, 200
                Send, {r Up}
                Sleep, 400
                Send, 2
            }
        }

        ; Skip rewards (berechnet)
        Sleep, 300
        MouseMove, %RewardX%, %RewardY%, 2
        Loop, 4 {
            Click
            Sleep, 300
        }

        ToolTip, Searching for Retry...
            GuiControl,, StatusText, Searching for retry button...
            imageList := ["image1920x1080.png", "image1366x768.png", "image1760x990.png", "image2560x1440.png", "image.png", "Image.png"] 

        Loop, 4 
        {
            for index, fileName in imageList 
            {
                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *60 %fileName%
                if (ErrorLevel = 0)
                {
                    MouseMove, %FoundX%, %FoundY%, 5
                    Sleep, 100
                    Click, 2
                    break 2 
                }
            }
            Sleep, 200 
        }

        GuiControl,, StatusText, Run completed - Waiting 7s...
        Sleep, 7000
    }
return

;===========================================
; HOTKEYS
;===========================================
F3::
    ActiveMethod := 1
    GuiControl,, MethodRadio1, 1
    Gosub, MethodSwitch
return

F4::
    ActiveMethod := 2
    GuiControl,, MethodRadio2, 1
    Gosub, MethodSwitch
return

F5::
    ActiveMethod := 3
    GuiControl,, MethodRadio3, 1
    Gosub, MethodSwitch
return

F2::
    GuiControl,, StatusText, Macro stopped!
    Reload 
return

GuiClose:
ESC::
ExitApp
return