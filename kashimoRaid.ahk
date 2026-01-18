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
MainGui := Gui("+AlwaysOnTop", "Raid Macro v9 - Kashimo")
MainGui.BackColor := "1a1a1a"
MainGui.SetFont("s10 cWhite", "Segoe UI")

MainGui.Add("Text", "x20 y15 w300 Center", "=== RAID MACRO CONTROLLER - Kashimo ===")

;--- Statistics Group ---
MainGui.Add("GroupBox", "x20 y50 w300 h100", "Statistics")
MainGui.SetFont("s11 Bold cLime")
RunCountText := MainGui.Add("Text", "x40 y75 w260 Center", "Runs: 0")
TimerText := MainGui.Add("Text", "x40 y100 w260 Center", "Time: 00:00:00")
MainGui.SetFont("s10 norm cWhite")

;--- Method Selection Group ---
; HÖHE ANGEPASST: h330 -> h380 für die Domain Checkbox
MainGui.Add("GroupBox", "x20 y160 w300 h380", "Configuration")

Radio1 := MainGui.Add("Radio", "x40 y190 w260 vMethodRadio1 Checked", "Method 1: All Moves (Not C move) | Only Slot 1 moves (Fast)")
Radio2 := MainGui.Add("Radio", "x40 y230 w260 vMethodRadio2", "Method 2: All Moves | Slot 1+2 |(Without C move)")
Radio3 := MainGui.Add("Radio", "x40 y270 w260 vMethodRadio3", "Method 3: All Moves | Slot 1+2 |(With C move)")
Radio4 := MainGui.Add("Radio", "x40 y310 w260 vMethodRadio4", "Method 4: fav methode | Sukuna only | (Attacks within Respawning)")

; --- RESET FELD (Farbe angepasst) ---
MainGui.Add("Text", "x40 y350 w120", "Initial Resets:")

; Background333333 macht den Hintergrund dunkelgrau
ResetInput := MainGui.Add("Edit", "x160 y347 w50 Number Center Background333333", "10")
MainGui.SetFont("s10 norm cWhite") ; Zurück zu Weiß

MainGui.Add("UpDown", "vResetCountRange Range0-50", 10)

; --- NEU: Domain Checkbox ---
DomainCheck := MainGui.Add("Checkbox", "x40 y390 w260 vDomainEnabled", "Enable Domain (Key T)")
; -----------------------------

Radio1.OnEvent("Click", MethodSwitch)
Radio2.OnEvent("Click", MethodSwitch)
Radio3.OnEvent("Click", MethodSwitch)
Radio4.OnEvent("Click", MethodSwitch)

; Info Text
MainGui.SetFont("s9 Bold cYellow")
MethodText := MainGui.Add("Text", "x40 y505 w260", "Active Method: 1")
MainGui.SetFont("s10 norm cWhite")

;--- Controls Group ---
MainGui.Add("GroupBox", "x20 y550 w300 h150", "Controls")
MainGui.Add("Text", "x40 y575 w260", "F1 = Start Macro")
MainGui.Add("Text", "x40 y595 w260", "F2 = Stop / Reload")
MainGui.Add("Text", "x40 y615 w260", "F3/F4/F5/F6 = Quick Switch")
MainGui.Add("Text", "x40 y635 w260", "F7 = Toggle Method 1-4")
MainGui.Add("Text", "x40 y655 w260", "ESC = Standard Game Function")

;--- Status Group ---
MainGui.Add("GroupBox", "x20 y710 w300 h60", "Status")
StatusText := MainGui.Add("Text", "x40 y735 w260 cLime", "Ready - Detected: " CurrentWidth "x" CurrentHeight)

MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.Show("w340 h790") ; Fensterhöhe angepasst

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
; HELPER FUNCTION - DOMAIN EXPANSION
;===========================================
PerformDomain() {
    ; Prüft, ob die Checkbox angehakt ist (Value 1 = an, 0 = aus)
    if (DomainCheck.Value = 1) {
        ToolTip("Using Domain Expansion (T)...")
        Sleep(2500)
        Send("{t Down}")
        Sleep(1000)
        Send("{t Up}")
        Sleep(2500)
    }
}

;===========================================
; HELPER FUNCTION - CHECK FOR RETRY
;===========================================
CheckForRetry() {
    global RunCount, RunCountText

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

        RunCount++
        RunCountText.Value := "Runs: " RunCount
        StatusText.Value := "Run #" RunCount " completed!"

        return true
    } else {
        return false
    }
}

;===========================================
; HELPER FUNCTION - INITIAL RESET LOOP
;===========================================
PerformInitialResets() {
    LoopCount := ResetInput.Value
    if (LoopCount = "")
        LoopCount := 0

    StatusText.Value := "Performing " LoopCount " Initial Resets..."

    Loop LoopCount {
        ToolTip("Initial Reset (" A_Index "/" LoopCount ")")

        Send("{Esc}")
        Sleep(300)
        Send("r")
        Sleep(300)
        Send("{Enter}")
        Sleep(300)

        if (ActiveMethod = 4) {
            Click(A_ScreenWidth/2, A_ScreenHeight/2)
            Sleep(300)

            Click("Right", A_ScreenWidth/2, A_ScreenHeight/2)
            Sleep(500)

            Sleep(2000)
            Send("1")
            Sleep(1000)
            Send("{x Down}")
            Sleep(1200)
            Send("{x Up}")
            Sleep(800)
            Send("1")
            Sleep(300) 
        }
        StatusText.Value := "Resets done. Starting attacks..."
        ToolTip("Resets done.")
        Sleep(1000)
    }
}

;===========================================
; MAIN LOOP - F1 TO START
;===========================================
F1:: {
    global ActiveMethod, StartTime, IsRunning

    if (!IsRunning) {
        StartTime := A_TickCount
        IsRunning := true
    }

    StatusText.Value := "Macro running... (Method " ActiveMethod ")"

    Loop {
        ToolTip("Waiting for 'start.png'...")

        Loop {
            if ImageSearch(&StartX, &StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*50 " . A_ScriptDir . "\start.png")
                break
            Sleep(2000)
        }

        ToolTip("Executing Method " ActiveMethod)
        StatusText.Value := "Start found - Running..."

        ; === ATTACK SEQUENCE ===
        if (ActiveMethod = 1) {
            ; METHOD 1
            PerformInitialResets()
            StatusText.Value := "Method 1 running..."
            AttackCycle := 0 

            Click(A_ScreenWidth/2, A_ScreenHeight/2)
            Sleep(300)

            Click("Right", A_ScreenWidth/2, A_ScreenHeight/2)
            Sleep(500)
            Loop {
                AttackCycle++
                ToolTip("Method 1 - Cycle " AttackCycle)

                Sleep(1000)
                Send("1")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)
                Sleep(500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(1500)

                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(1500)

                Send("1")

                ; --- DOMAIN CHECK ---
                PerformDomain() 
                ; --------------------

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 2) {
            ; METHOD 2
            PerformInitialResets()
            StatusText.Value := "Method 2 running..."
            AttackCycle := 0 
            Click(A_ScreenWidth/2, A_ScreenHeight/2)
            Sleep(300)

            Click("Right", A_ScreenWidth/2, A_ScreenHeight/2)
            Sleep(500)
            Loop {
                AttackCycle++
                ToolTip("Method 2 - Cycle " AttackCycle)

                ; First Attack - Slot 1
                Sleep(1000)
                Send("1")
                Sleep(500)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(1500)

                Sleep(500)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(1500)

                ; Second Attack - Slot 2
                Sleep(1000)
                Send("2")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(1500)

                Sleep(500)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(1500)

                ; --- DOMAIN CHECK ---
                PerformDomain() 
                ; --------------------

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 3) {
            ; METHOD 3
            PerformInitialResets()
            StatusText.Value := "Method 3 running..."
            AttackCycle := 0 
            Click(A_ScreenWidth/2, A_ScreenHeight/2)
            Sleep(300)

            Click("Right", A_ScreenWidth/2, A_ScreenHeight/2)
            Sleep(500)
            Loop {
                AttackCycle++
                ToolTip("Method 3 - Cycle " AttackCycle)

                Sleep(1000)
                Send("1")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(500)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(1500)

                Sleep(500)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(2000)

                Send("{c Down}")
                Sleep(1000)
                Send("{c Up}")
                Sleep(1500)

                Send("2")
                Sleep(500)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(900)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(1500)

                Sleep(900)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(2000)

                Send("{c Down}")
                Sleep(1000)
                Send("{c Up}")
                Sleep(1500)

                ; --- DOMAIN CHECK ---
                PerformDomain() 
                ; --------------------

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 4) {
            ; METHOD 4
            PerformInitialResets()
            StatusText.Value := "Method 4 running..."
            AttackCycle := 0 

            Loop {
                AttackCycle++
                ToolTip("Method 4 - Cycle " AttackCycle)

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
                Sleep(6000)
                Send("1")

                ; --- DOMAIN CHECK ---
                PerformDomain() 
                ; --------------------

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
    StatusText.Value := "Method " ActiveMethod " activated"
    MethodText.Value := "Active Method: " ActiveMethod
}

F2:: {
    global IsRunning, RunCount, StartTime
    IsRunning := false
    RunCount := 0
    StartTime := 0
    StatusText.Value := "Macro reloaded!"
    Reload()
}