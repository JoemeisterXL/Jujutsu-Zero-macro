;===========================================
; CONFIGURATION & SCALING LOGIC
;===========================================
#Requires AutoHotkey v2.0
#SingleInstance Force

; Sets the working directory to the script folder
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
MainGui := Gui("+AlwaysOnTop", "Raid Macro v6 - kashimo")
MainGui.BackColor := "1a1a1a"
MainGui.SetFont("s10 cWhite", "Segoe UI")

MainGui.Add("Text", "x20 y15 w300 Center", "=== RAID MACRO CONTROLLER - kashimo ===")

;--- Statistics Group ---
MainGui.Add("GroupBox", "x20 y50 w300 h100", "Statistics")
MainGui.SetFont("s11 Bold cLime")
RunCountText := MainGui.Add("Text", "x40 y75 w260 Center", "Runs: 0")
TimerText := MainGui.Add("Text", "x40 y100 w260 Center", "Time: 00:00:00")
MainGui.SetFont("s10 norm cWhite")

;--- Method Selection Group ---
; HIER WURDE VERSCHOBEN: Alt 2->1, Alt 3->2, Alt 4->3
MainGui.Add("GroupBox", "x20 y160 w300 h250", "Method Selection")
Radio1 := MainGui.Add("Radio", "x40 y225 w260 vMethodRadio1 Checked", "Method 1: Keybind R | Slot 1 (Fast | No ult attack (like fuga)) (4x Start Reset)")
Radio2 := MainGui.Add("Radio", "x40 y265 w260 vMethodRadio2", "Method 2: All Moves (No ult attack, like fuga) | Slot 1+2 (4x Start Reset)")
Radio3 := MainGui.Add("Radio", "x40 y305 w260 vMethodRadio3", "Method 3: All Moves (4x Start Reset)")

Radio1.OnEvent("Click", MethodSwitch)
Radio2.OnEvent("Click", MethodSwitch)
Radio3.OnEvent("Click", MethodSwitch)

; Info Text
MainGui.SetFont("s9 Bold cYellow")
MethodText := MainGui.Add("Text", "x40 y375 w260", "Active Method: 1")
MainGui.SetFont("s10 norm cWhite")

;--- Controls Group ---
MainGui.Add("GroupBox", "x20 y420 w300 h130", "Controls")
MainGui.Add("Text", "x40 y445 w260", "F1 = Start Macro")
MainGui.Add("Text", "x40 y465 w260", "F2 = Stop / Reload")
MainGui.Add("Text", "x40 y485 w260", "F3/F4/F5 = Quick Switch")
MainGui.Add("Text", "x40 y505 w260", "F7 = Toggle Method 1-3")
MainGui.Add("Text", "x40 y525 w260", "ESC = Standard Game Function (Ignored)")

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

        return true
    } else {
        return false
    }
}

;===========================================
; HELPER FUNCTION - 5x INITIAL RESET
;===========================================
PerformInitialResets() {
    StatusText.Value := "Performing 5 Initial Resets..."
    Loop 4 {
        ToolTip("Initial Reset (" A_Index "/4) - Dont do anything! within respawring (Just to be sure the boss has the focus)")

        Send("{Esc}")
        Sleep(300)
        Send("r")
        Sleep(300)
        Send("{Enter}")

        ; Wait for respawn (Adjust if too slow/fast)
        Sleep(5500) 
    }
    StatusText.Value := "Resets done. Starting attacks..."
    ToolTip("Resets done.")
    Sleep(1000)
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
            ; METHOD 1 (War vorher 2): Fast - Slot 1 with R keybind

            ; --- 5x INITIAL RESET ---
            PerformInitialResets()
            ; ------------------------

            StatusText.Value := "Method 1: Looping until Retry found..."
            AttackCycle := 0 

            Loop {
                AttackCycle++
                ToolTip("Method 1 - Attack Cycle " AttackCycle)

                Sleep(1000)
                Send("1")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(500)

                Sleep(500)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(500)
                Send("1")

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 2) {
            ; METHOD 2 (War vorher 3): Double Attack - Slot 1 + Slot 2 with R keybind

            ; --- 5x INITIAL RESET ---
            PerformInitialResets()
            ; ------------------------

            StatusText.Value := "Method 2: Looping until Retry found..."
            AttackCycle := 0 

            Loop {
                AttackCycle++
                ToolTip("Method 2 - Double Attack Cycle " AttackCycle)

                ; First Attack - Slot 1
                Sleep(1000)
                Send("1")
                Sleep(500)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(500)

                Sleep(500)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(500)
                ; Second Attack - Slot 2
                Sleep(1000)
                Send("2")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(500)

                Sleep(500)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(500)

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 3) {
            ; METHOD 3 (War vorher 4): Click center before C press

            ; --- 5x INITIAL RESET ---
            PerformInitialResets()
            ; ------------------------

            StatusText.Value := "Method 3: Looping until Retry found..."
            AttackCycle := 0 

            Loop {
                AttackCycle++
                ToolTip("Method 3 - Attack Cycle " AttackCycle)

                ; First Attack - Slot 1
                Sleep(1000)
                Send("1")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(500)

                Sleep(500)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(500)
                Send("{c Down}")
                Sleep(1000)
                Send("{c Up}")
                Sleep(500)

                ; Second Attack - Slot 2
                Sleep(1000)
                Send("2")
                Sleep(500)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(500)

                Sleep(500)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(500)

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
    MethodSwitch()
}

F4:: {
    global ActiveMethod
    Radio1.Value := 0
    Radio2.Value := 1
    Radio3.Value := 0
    MethodSwitch()
}

F5:: {
    global ActiveMethod
    Radio1.Value := 0
    Radio2.Value := 0
    Radio3.Value := 1
    MethodSwitch()
}

F7:: {
    global ActiveMethod
    ActiveMethod := Mod(ActiveMethod, 3) + 1 ; Toggle 1-3

    Radio1.Value := (ActiveMethod = 1)
    Radio2.Value := (ActiveMethod = 2)
    Radio3.Value := (ActiveMethod = 3)

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