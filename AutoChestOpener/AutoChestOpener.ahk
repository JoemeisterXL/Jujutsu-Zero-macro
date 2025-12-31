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

; Deine Referenz-Auflösung
RefWidth := 1920
RefHeight := 1080

; Aktuelle Auflösung des Nutzers
CurrentWidth := A_ScreenWidth
CurrentHeight := A_ScreenHeight

; Skalierungsfaktoren
ScaleX := CurrentWidth / RefWidth
ScaleY := CurrentHeight / RefHeight

; Feste Koordinaten (skaliert)
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

;--- Checkbox Group für Bilder ---
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
    ; GUI auslesen, um zu sehen was angehakt ist
    Gui, Submit, NoHide

    ; Array der Bilder basierend auf Auswahl erstellen
    ActiveImages := []
    if (CheckCrate1)
        ActiveImages.Push("Strengthened_Crate1.png")
    if (CheckCrate2)
        ActiveImages.Push("Strengthened_Crate2.png")
    if (CheckJolly)
        ActiveImages.Push("Jolly_Crate.png")
    if (CheckVolcanic)
        ActiveImages.Push("Volcanic_Crate.png")

    if (ActiveImages.Length() = 0) {
        GuiControl,, StatusText, Error: No image selected!
        return
    }

    GuiControl,, StatusText, Macro running...
    Loop
    {
        ; 1. Ausgewählte Bilder suchen
        for index, imageName in ActiveImages
        {
            ToolTip, Searching: %imageName%
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
        ToolTip

        ; 2. ZUERST Neue Position (1732, 975 skaliert)
        GuiControl,, StatusText, Clicking Pos 1732...
        MouseMove, %PNew_X%, %PNew_Y%, 2
        Sleep, 200
        Click, %PNew_X%, %PNew_Y%

        Sleep, 1000

        ; 3. DANACH Alte Position (1800, 109 skaliert)
        GuiControl,, StatusText, Clicking Pos 1800...
        MouseMove, %POld_X%, %POld_Y%, 2
        Sleep, 200
        Click, %POld_X%, %POld_Y%
        Sleep, 400
        Click, %POld_X%, %POld_Y%
        Sleep, 900
        Click, %POld_X%, %POld_Y%

        Sleep, 1000
    }
return

F2:: Reload
Esc:: ExitApp