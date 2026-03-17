;===========================================
; CONFIGURATION & SCALING LOGIC
;===========================================
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SendMode Event
SetDefaultMouseSpeed, 0

; Your Reference Resolution (The res you used to find the coordinates)
RefWidth := 1920
RefHeight := 1080

; Automatically detect the user's current resolution
CurrentWidth := A_ScreenWidth
CurrentHeight := A_ScreenHeight

; Calculate scaling factors
ScaleX := CurrentWidth / RefWidth
ScaleY := CurrentHeight / RefHeight

; Prepare fixed coordinates (scaled)
PNew_X := 1732 * ScaleX
PNew_Y := 975 * ScaleY
POld_X := 1800 * ScaleX
POld_Y := 109 * ScaleY

;===========================================
; CREATE GUI
;===========================================
Gui, +AlwaysOnTop
Gui, Color, 0x1a1a1a
Gui, Font, s10 cWhite, Segoe UI

Gui, Add, Text, x20 y15 w300 Center, === RAID MACRO CONTROLLER ===

;--- Checkbox Group for Images ---
Gui, Add, GroupBox, x20 y50 w300 h130, Select Images to Search
Gui, Add, Checkbox, x40 y75 w240 vCheckCrate1, Strengthened Crate 1
Gui, Add, Checkbox, x40 y95 w240 vCheckCrate2, Strengthened Crate 2
Gui, Add, Checkbox, x40 y115 w240 vCheckJolly, Jolly Crate
Gui, Add, Checkbox, x40 y135 w240 vCheckVolcanic, Volcanic Crate

;--- Controls Group ---
Gui, Add, GroupBox, x20 y190 w300 h110, Controls
Gui, Add, Text, x40 y215 w260, F1 = Start Macro
Gui, Add, Text, x40 y235 w260, F2 = Stop / Reload
Gui, Add, Text, x40 y255 w260, ESC = Close GUI

;--- Status Group ---
Gui, Add, GroupBox, x20 y310 w300 h60, Status
Gui, Add, Text, x40 y335 w260 vStatusText cLime, Ready - Select and Press F1

Gui, Show, w340 h390, Raid Macro v2.1
return

;===========================================
; MAIN LOOP - F1 TO START
;===========================================
F1::
    ; Read GUI state to see which boxes are checked
    Gui, Submit, NoHide

    ; Create an array of images based on selection
    ActiveImages := []
    if (CheckCrate1)
        ActiveImages.Push("Strengthened_Crate1.png")
    if (CheckCrate2)
        ActiveImages.Push("Strengthened_Crate2.png")
    if (CheckJolly)
        ActiveImages.Push("Jolly_Crate.png")
    if (CheckVolcanic)
        ActiveImages.Push("Volcanic_Crate.png")

    ; Safety check: Ensure at least one image is selected
    if (ActiveImages.Length() = 0) {
        GuiControl,, StatusText, Error: No image selected!
        return
    }

    GuiControl,, StatusText, Macro running...
    Loop
    {
        ; 1. SEARCH FOR SELECTED IMAGES
        for index, imageName in ActiveImages
        {
            ToolTip, Searching: %imageName%
            ; Search with *50 variation for color tolerance
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 %imageName%

            if (ErrorLevel = 0)
            {
                GuiControl,, StatusText, Found: %imageName%
                MouseMove, %FoundX%, %FoundY%, 2
                Sleep, 100
                Click, %FoundX%, %FoundY%
                Sleep, 500
            }
        }
        ToolTip ; Remove ToolTip

        ; 2. CLICK NEW POSITION FIRST (1732, 975 scaled)
        GuiControl,, StatusText, Clicking Pos 1732...
        MouseMove, %PNew_X%, %PNew_Y%, 2
        Sleep, 200
        Click, %PNew_X%, %PNew_Y%

        Sleep, 1000

        ; 3. CLICK OLD POSITION NEXT (1800, 109 scaled)
        GuiControl,, StatusText, Clicking Pos 1800...
        MouseMove, %POld_X%, %POld_Y%, 2
        Sleep, 200
        Click, %POld_X%, %POld_Y%
        Sleep, 400
        Click, %POld_X%, %POld_Y%
        Sleep, 900
        Click, %POld_X%, %POld_Y%

        Sleep, 1000 ; Wait before starting the next full loop
    }
return

F2:: Reload
Esc:: ExitApp