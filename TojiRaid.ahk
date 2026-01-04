;===========================================
; CONFIGURATION & SCALING LOGIC
;===========================================
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScreenHeight%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SendMode Event
SetDefaultMouseSpeed, 0

; Reference Resolution (The res you used to set the points)
RefWidth := 1920
RefHeight := 1080

; Detect current resolution
CurrentWidth := A_ScreenWidth
CurrentHeight := A_ScreenHeight

; Calculate scaling factors
ScaleX := CurrentWidth / RefWidth
ScaleY := CurrentHeight / RefHeight

; Scaled Coordinates
; Target 1: Skill/Attack Click (747, 413)
Target1_X := 747 * ScaleX
Target1_Y := 413 * ScaleY

; Target 2: Skip Rewards Click (10, 240)
Target2_X := 10 * ScaleX
Target2_Y := 240 * ScaleY

;--- Default Method ---
ActiveMethod := 1

;===========================================
; CREATE GUI
;===========================================
Gui, +AlwaysOnTop
Gui, Color, 0x1a1a1a
Gui, Font, s10 cWhite, Segoe UI

Gui, Add, Text, x20 y15 w300 Center, === RAID MACRO CONTROLLER ===

;--- Method Selection Group ---
Gui, Add, GroupBox, x20 y50 w300 h150, Method Selection
Gui, Add, Radio, x40 y75 w260 vMethodRadio1 gMethodSwitch Checked, Method 1: Slot 1 move
Gui, Add, Radio, x40 y105 w260 vMethodRadio2 gMethodSwitch, Method 2: Both Slots

; Info Text
Gui, Font, s9 Bold cYellow
Gui, Add, Text, x40 y175 w260 vMethodText, Active Method: 1
Gui, Font, s10 norm cWhite

;--- Controls Group ---
Gui, Add, GroupBox, x20 y210 w300 h110, Controls
Gui, Add, Text, x40 y235 w260, F1 = Start Macro
Gui, Add, Text, x40 y255 w260, F2 = Stop / Reload
Gui, Add, Text, x40 y275 w260, F3/F4/F5 = Quick Switch
Gui, Add, Text, x40 y295 w260, ESC = Close GUI

;--- Status Group ---
Gui, Add, GroupBox, x20 y330 w300 h60, Status
Gui, Add, Text, x40 y355 w260 vStatusText cLime, Ready - Detected: %CurrentWidth%x%CurrentHeight%

Gui, Show, w340 h410, Raid Macro v2.2
return

;===========================================
; METHOD SWITCH LOGIC
;===========================================
MethodSwitch:
    Gui, Submit, NoHide
    if (MethodRadio1)
        ActiveMethod := 1
    else if (MethodRadio2)
        ActiveMethod := 2

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

        ToolTip, Executing Method %ActiveMethod%
        GuiControl,, StatusText, Start found - Running...

        ; === CAMERA ROTATION & BLUE1 SEARCH ===
        FoundBlue := false
        Loop, 20
        {
            ToolTip, Searching for Toji.png (Attempt %A_Index%/20)...
            GuiControl,, StatusText, Searching Toji.png (%A_Index%/20)...

            ; Search multiple times for 7 seconds
            SearchStartTime := A_TickCount
            Loop
            {
                ImageSearch, BlueX, BlueY, 0, 0, A_ScreenWidth, A_ScreenHeight, *60 Toji.png

                if (ErrorLevel = 0)
                {
                    ToolTip, Toji.png found! Moving mouse to position...
                    GuiControl,, StatusText, Toji.png found! Clicking...
                    FoundBlue := true

                    ; Move mouse to the found blue1.png position
                    MouseMove, %BlueX%, %BlueY%, 5
                    Sleep, 300

                    ; Click on the blue1.png position
                    Click
                    Sleep, 500

                    break 2
                }

                ; Check if 7 seconds have passed
                if (A_TickCount - SearchStartTime > 7000)
                    break

                Sleep, 200 ; Search frequently (ca. 35 times in 7 seconds)
            }

            if (FoundBlue)
                break

            ; Rotate camera to the right (Roblox style)
            ToolTip, Toji.png not found - Rotating camera right...

            ; Hold right mouse button and drag to rotate
            Click, Right, Down
            Sleep, 100

            ; Move mouse to the right using DllCall for precise control
            ; 185 pixels to the right, 0 pixels vertically (bleibt auf einer Linie)
            DllCall("mouse_event", "UInt", 0x0001, "Int", 185, "Int", 0, "UInt", 0, "UPtr", 0)
            Sleep, 200

            ; Release right mouse button
            Click, Right, Up

            ; Move mouse back to center of screen to reset position
            CenterX := A_ScreenWidth / 2
            CenterY := A_ScreenHeight / 2
            MouseMove, %CenterX%, %CenterY%, 0

            Sleep, 2000 ; Wait longer for camera to stabilize
        }

        if (!FoundBlue)
        {
            ToolTip, Warning: blue1.png not found after 20 attempts!
            GuiControl,, StatusText, WARNING: blue1.png not found!
            Sleep, 2000
        }

        ToolTip

        ; === ATTACK SEQUENCE ===
        if (ActiveMethod = 1)
        {
            Sleep, 2000
            Send, 1
            Sleep, 800
            Send, {c Down}
            Sleep, 800
            Send, {c Up}
            Sleep, 7000
        }
        else if (ActiveMethod = 2)
        {
            Sleep, 2000
            Send, 1
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

        ; Skip rewards (Target 2)
        Sleep, 4000
        MouseMove, %Target2_X%, %Target2_Y%
        Loop, 4 {
            Click
            Sleep, 500
        }

        ToolTip, Searching for Retry...
            GuiControl,, StatusText, Searching for retry button...
            retryImages := ["image1920x1080.png", "image1366x768.png", "image1760x990.png", "image2560x1440.png", "image.png"]

        Loop, 4
        {
            for index, fileName in retryImages
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
            Sleep, 1000
        }

        GuiControl,, StatusText, Cycle done - Waiting 15s...
        Sleep, 15000
    }
return

;===========================================
; HOTKEYS FOR QUICK SWITCH
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

;===========================================
; EXIT / STOP
;===========================================
F2::
    GuiControl,, StatusText, Macro reloaded!
    Reload
return

GuiClose:
ESC::
ExitApp
return