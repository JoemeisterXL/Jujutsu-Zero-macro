;===========================================
; CONFIGURATION & SCALING LOGIC
;===========================================
#Requires AutoHotkey v2.0
#SingleInstance Force

; Setzt das Arbeitsverzeichnis auf den Skriptordner
SetWorkingDir(A_ScriptDir) 

CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")
SendMode("Event")
SetDefaultMouseSpeed(0)

; Reference Resolution
RefWidth := 1920
RefHeight := 1080

; Detect current resolution
CurrentWidth := A_ScreenWidth
CurrentHeight := A_ScreenHeight

; Calculate scaling factors
ScaleX := CurrentWidth / RefWidth
ScaleY := CurrentHeight / RefHeight

; Scaled Coordinates
Target1_X := 747 * ScaleX
Target1_Y := 413 * ScaleY
Target2_X := 10 * ScaleX
Target2_Y := 240 * ScaleY

;--- Default Method ---
global ActiveMethod := 1

;--- Timer & Counter Variables ---
global RunCount := 0
global StartTime := 0
global IsRunning := false

;===========================================
; CREATE GUI
;===========================================
MainGui := Gui("+AlwaysOnTop", "Raid Macro v5.1 - Jogo")
MainGui.BackColor := "1a1a1a"
MainGui.SetFont("s10 cWhite", "Segoe UI")

MainGui.Add("Text", "x20 y15 w300 Center", "=== RAID MACRO CONTROLLER - Jogo ===")

;--- Statistics Group ---
MainGui.Add("GroupBox", "x20 y50 w300 h100", "Statistics")
MainGui.SetFont("s11 Bold cLime")
RunCountText := MainGui.Add("Text", "x40 y75 w260 Center", "Runs: 0")
TimerText := MainGui.Add("Text", "x40 y100 w260 Center", "Time: 00:00:00")
MainGui.SetFont("s10 norm cWhite")

;--- Method Selection Group ---
MainGui.Add("GroupBox", "x20 y160 w300 h250", "Method Selection")
Radio1 := MainGui.Add("Radio", "x40 y185 w260 vMethodRadio1 Checked", "Method 1: Image Search | Slot 1 (NOT WORKING To find the images)")
Radio2 := MainGui.Add("Radio", "x40 y225 w260 vMethodRadio2", "Method 2: right,left,above -> keybind R | Slot 1 (Fast) (Shrine works best)")
Radio3 := MainGui.Add("Radio", "x40 y265 w260 vMethodRadio3", "Method 3: right,left,above -> keybind R | Slot 1+2 keybind R (Shrine works best)")
Radio4 := MainGui.Add("Radio", "x40 y305 w260 vMethodRadio4", "Method 4: right,left,above -> keybind R | R + C move (Not recommended)")

Radio1.OnEvent("Click", MethodSwitch)
Radio2.OnEvent("Click", MethodSwitch)
Radio3.OnEvent("Click", MethodSwitch)
Radio4.OnEvent("Click", MethodSwitch)

; Info Text
MainGui.SetFont("s9 Bold cYellow")
MethodText := MainGui.Add("Text", "x40 y375 w260", "Active Method: 1")
MainGui.SetFont("s10 norm cWhite")

;--- Controls Group ---
MainGui.Add("GroupBox", "x20 y420 w300 h130", "Controls")
MainGui.Add("Text", "x40 y445 w260", "F1 = Start Macro")
MainGui.Add("Text", "x40 y465 w260", "F2 = Stop / Reload")
MainGui.Add("Text", "x40 y485 w260", "F3/F4/F5/F6 = Quick Switch")
MainGui.Add("Text", "x40 y505 w260", "F7 = Toggle Method 1-4")
MainGui.Add("Text", "x40 y525 w260", "ESC = Close GUI")

;--- Status Group ---
MainGui.Add("GroupBox", "x20 y560 w300 h60", "Status")
StatusText := MainGui.Add("Text", "x40 y585 w260 cLime", "Ready - Detected: " CurrentWidth "x" CurrentHeight)

MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.Show("w340 h640")

;===========================================
; TIMER UPDATE FUNCTION
;===========================================
UpdateTimer() {
    global StartTime, IsRunning, TimerText

    if (!IsRunning)
        return

    ElapsedSeconds := (A_TickCount - StartTime) // 1000
    Hours := ElapsedSeconds // 3600
    Minutes := Mod(ElapsedSeconds // 60, 60)
    Seconds := Mod(ElapsedSeconds, 60)

    TimeString := Format("{:02d}:{:02d}:{:02d}", Hours, Minutes, Seconds)
    TimerText.Value := "Time: " TimeString
}

; Start Timer
SetTimer(UpdateTimer, 1000)

;===========================================
; METHOD SWITCH LOGIC
;===========================================
MethodSwitch(*) {
    global ActiveMethod
    if (Radio1.Value)
        ActiveMethod := 1
    else if (Radio2.Value)
        ActiveMethod := 2
    else if (Radio3.Value)
        ActiveMethod := 3
    else if (Radio4.Value)
        ActiveMethod := 4

    StatusText.Value := "Method " ActiveMethod " activated"
    MethodText.Value := "Active Method: " ActiveMethod
}

;===========================================
; HELPER FUNCTION - CHECK FOR RETRY BUTTON
;===========================================
CheckForRetry() {
    global RunCount, RunCountText

    ; === RETRY BUTTON SEARCH ===
    ToolTip("Searching for Retry...")
    StatusText.Value := "Searching for retry button..."

    if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*60 retry.png") {
        MouseMove(FoundX, FoundY, 5)
        Sleep(500)
        Click(4)
        Sleep(700)
        MouseMove(FoundX + 3, FoundY + 3, 5)
        Sleep(500)
        Click()

        ; Increment Run Counter
        RunCount++
        RunCountText.Value := "Runs: " RunCount
        StatusText.Value := "Run #" RunCount " completed!"

        foundRetry := true
    } else {
        foundRetry := false
    }

    return foundRetry
}

;===========================================
; MAIN LOOP - F1 TO START
;===========================================
F1:: {
    global ActiveMethod, StartTime, IsRunning

    ; Start Timer on first run
    if (!IsRunning) {
        StartTime := A_TickCount
        IsRunning := true
    }

    StatusText.Value := "Macro running... (Method " ActiveMethod ")"

    Loop {
        ToolTip("Waiting for 'start.png'...")

        ; Look for the start image
        Loop {
            if ImageSearch(&StartX, &StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*50 " . A_ScriptDir . "\start.png")
                break
            Sleep(2000)
        }

        ToolTip("Executing Method " ActiveMethod)
        StatusText.Value := "Start found - Running..."
        ToolTip("Start found - Running...")

        ; === ATTACK SEQUENCE ===
        if (ActiveMethod = 1) {
            ; METHOD 1: Original Jogo Image Search with Camera Rotation
            FoundBlue := false
            Loop 20 {
                ToolTip("Searching JogoPng Folder (Attempt " A_Index "/20)...")
                StatusText.Value := "Searching JogoPng (" A_Index "/20)..."
                SearchStartTime := A_TickCount
                Loop {
                    Loop Files, A_ScriptDir . "\JogoPng\*.png" 
                    {
                        if ImageSearch(&BlueX, &BlueY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*55 " . A_LoopFileFullPath) 
                        {
                            ToolTip("Jogo Found: " . A_LoopFileName)
                            StatusText.Value := "Jogo found! Clicking..."
                            FoundBlue := true

                            MouseMove(BlueX, BlueY, 5)
                            Sleep(300)
                            Click()
                            Sleep(500)
                            break 3
                        }
                    }

                    if (A_TickCount - SearchStartTime > 7000)
                        break

                    Sleep(200)
                }

                if (FoundBlue)
                    break

                ; Rotate camera to the right
                ToolTip("Jogo not found - Rotating camera right...")
                Click("Right Down")
                Sleep(100)
                DllCall("mouse_event", "UInt", 0x0001, "Int", 185, "Int", 0, "UInt", 0, "UPtr", 0)
                Sleep(200)
                Click("Right Up")

                CenterX := A_ScreenWidth / 2
                CenterY := A_ScreenHeight / 2
                MouseMove(CenterX, CenterY, 0)
                Sleep(2000)
            }

            if (!FoundBlue) {
                ToolTip("Warning: No image in JogoPng found!")
                StatusText.Value := "WARNING: JogoPng not found!"
                Sleep(2000)
            }

            ToolTip()
            Sleep(2000)
            Send("1")
            Sleep(800)
            Send("{c Down}")
            Sleep(800)
            Send("{c Up}")
            Sleep(7000)

            if CheckForRetry()
                break
            Sleep(1000)

        } else if (ActiveMethod = 2) {
            ; METHOD 2: Fast - Slot 1 with R keybind - Loop until Retry found
            StatusText.Value := "Method 2: Looping until Retry found..."

            Loop {
                ToolTip("Method 2 - Attack Cycle " A_Index)
                Sleep(1000)
                Send("1")
                Sleep(800)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(800)
                Send("1")
                Sleep(500)

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 3) {
            ; METHOD 3: Double Attack - Slot 1 + Slot 2 with R keybind - Loop until Retry found
            StatusText.Value := "Method 3: Looping until Retry found..."

            Loop {
                ToolTip("Method 3 - Double Attack Cycle " A_Index)

                ; First Attack - Slot 1
                Sleep(2000)
                Send("1")
                Sleep(800)
                Send("{r Down}")
                Sleep(1200)
                Send("{r Up}")
                Sleep(800)
                ; Second Attack - Slot 2
                Send("2")
                Sleep(800)
                Send("{r Down}")
                Sleep(1200)
                Send("{r Up}")
                Sleep(500)

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 4) {
            ; METHOD 4: Click center before C press
            StatusText.Value := "Method 4: Looping until Retry found..."

            Loop {
                ToolTip("Method 4 - Attack Cycle " A_Index)

                ; Calculate screen center
                CenterX := A_ScreenWidth / 2
                CenterY := A_ScreenHeight / 2

                ; First Attack - Slot 1
                Sleep(2000)
                Send("1")
                Sleep(800)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(1500)

                ; Click center before C press
                MouseMove(CenterX, CenterY, 0)
                Sleep(800)
                Click()
                Sleep(800)

                Send("{c Down}")
                Sleep(1000)
                Send("{c Up}")
                Sleep(1500)

                ; Second Attack - Slot 2
                Send("2")
                Sleep(800)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(1300)

                ; Click center before C press
                MouseMove(CenterX, CenterY, 0)
                Sleep(800)
                Click()
                Sleep(800)

                Send("{c Down}")
                Sleep(1000)
                Send("{c Up}")
                Sleep(1500)

                if CheckForRetry()
                    break
                Sleep(1000)
            }
        }

        ToolTip()
        StatusText.Value := "Cycle done - Waiting 15s..."
        Sleep(15000)
    }
}

;===========================================
; HOTKEYS FOR QUICK SWITCH
;===========================================
F3:: {
    global ActiveMethod
    Radio1.Value := 1
    Radio2.Value := 0
    Radio3.Value := 0
    Radio4.Value := 0
    MethodSwitch()
}

F4:: {
    global ActiveMethod
    Radio1.Value := 0
    Radio2.Value := 1
    Radio3.Value := 0
    Radio4.Value := 0
    MethodSwitch()
}

F5:: {
    global ActiveMethod
    Radio1.Value := 0
    Radio2.Value := 0
    Radio3.Value := 1
    Radio4.Value := 0
    MethodSwitch()
}

F6:: {
    global ActiveMethod
    Radio1.Value := 0
    Radio2.Value := 0
    Radio3.Value := 0
    Radio4.Value := 1
    MethodSwitch()
}

F7:: {
    global ActiveMethod
    ActiveMethod := Mod(ActiveMethod, 4) + 1

    Radio1.Value := (ActiveMethod = 1)
    Radio2.Value := (ActiveMethod = 2)
    Radio3.Value := (ActiveMethod = 3)
    Radio4.Value := (ActiveMethod = 4)

    StatusText.Value := "Method " ActiveMethod " activated (Toggle)"
    MethodText.Value := "Active Method: " ActiveMethod
}

;===========================================
; EXIT / STOP
;===========================================
F2:: {
    global IsRunning, RunCount, StartTime

    IsRunning := false
    RunCount := 0
    StartTime := 0

    StatusText.Value := "Macro reloaded!"
    Reload()
}

ESC:: ExitApp()