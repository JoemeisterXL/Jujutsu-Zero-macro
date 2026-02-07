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

;--- Default Method ---
global ActiveMethod := 2 
global UseDomain := false 

;--- Timer & Counter Variables ---
global RunCount := 0
global StartTime := 0
global IsRunning := false

;===========================================
; CREATE GUI
;===========================================
MainGui := Gui("+AlwaysOnTop", "Raid Macro v6 - Sukuna")
MainGui.BackColor := "1a1a1a"
MainGui.SetFont("s10 cWhite", "Segoe UI")

MainGui.Add("Text", "x20 y15 w300 Center", "=== RAID MACRO CONTROLLER - Sukuna ===")

;--- Statistics Group ---
MainGui.Add("GroupBox", "x20 y50 w300 h100", "Statistics")
MainGui.SetFont("s11 Bold cLime")
RunCountText := MainGui.Add("Text", "x40 y75 w260 Center", "Runs: 0")
TimerText := MainGui.Add("Text", "x40 y100 w260 Center", "Time: 00:00:00")
MainGui.SetFont("s10 norm cWhite")

;--- Method Selection Group ---
MainGui.Add("GroupBox", "x20 y160 w300 h330", "Method Selection")

; --- Method 2 ---
Radio2 := MainGui.Add("Radio", "x40 y185 w260 vMethodRadio2 Checked", "Method 2: Keybind R | Slot 1 (Fast)")
InfoBtn2 := MainGui.Add("Button", "x55 y208 w80 h22", "Info")
InfoBtn2.SetFont("s8")

; --- Method 3 ---
Radio3 := MainGui.Add("Radio", "x40 y240 w260 vMethodRadio3", "Method 3: Slot 1+2 (No Ult)")
InfoBtn3 := MainGui.Add("Button", "x55 y263 w80 h22", "Info")
InfoBtn3.SetFont("s8")

; --- Method 4 ---
Radio4 := MainGui.Add("Radio", "x40 y295 w260 vMethodRadio4", "Method 4: Slot 1+2 + Ult")
InfoBtn4 := MainGui.Add("Button", "x55 y318 w80 h22", "Info")
InfoBtn4.SetFont("s8")

; --- Domain Checkbox ---
MainGui.SetFont("s10 Bold cYellow")
DomainCheck := MainGui.Add("Checkbox", "x40 y355 w260 vDomainEnabled", "Enable Domain (T)")
MainGui.SetFont("s10 norm cWhite")

; --- Event Handlers ---
Radio2.OnEvent("Click", MethodSwitch)
Radio3.OnEvent("Click", MethodSwitch)
Radio4.OnEvent("Click", MethodSwitch)
DomainCheck.OnEvent("Click", DomainToggle)

InfoBtn2.OnEvent("Click", ShowInfo2)
InfoBtn3.OnEvent("Click", ShowInfo3)
InfoBtn4.OnEvent("Click", ShowInfo4)

; Info Text
MainGui.SetFont("s9 Bold cYellow")
MethodText := MainGui.Add("Text", "x40 y405 w260", "Active Method: 2")
MainGui.SetFont("s10 norm cWhite")

;--- Controls Group ---
MainGui.Add("GroupBox", "x20 y440 w300 h130", "Controls")
MainGui.Add("Text", "x40 y465 w260", "F1 = Start Macro")
MainGui.Add("Text", "x40 y485 w260", "F2 = Stop / Reload")
MainGui.Add("Text", "x40 y505 w260", "F4/F5/F6 = Quick Switch")
MainGui.Add("Text", "x40 y525 w260", "F7 = Toggle Method 2-4")
MainGui.Add("Text", "x40 y545 w260", "ESC = Close GUI")

;--- Status Group ---
MainGui.Add("GroupBox", "x20 y580 w300 h60", "Status")
StatusText := MainGui.Add("Text", "x40 y605 w260 cLime", "Ready - Detected: " CurrentWidth "x" CurrentHeight)

MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.Show("w340 h660")

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
; INFO POPUP FUNCTIONS (ALWAYS ON TOP)
;===========================================
ShowInfo2(*) {
    ; 4096 = System Modal (Always On Top)
    MsgBox("METHOD 2 DETAILS:`n`n"
         . "- Speed: Fast`n"
         . "- Moves: Uses only Slot 1.`n"
         . "- Keybinds: Uses 'R', 'F'and 'X'.`n"
         . "- Ultimate: NO Ultimate used.`n`n"
         . "Recommended for: Fast farming where Ultimate is not needed.", "Method 2 Info", 4096)
}

ShowInfo3(*) {
    ; 4096 = System Modal (Always On Top)
    MsgBox("METHOD 3 DETAILS:`n`n"
         . "- Speed: Medium`n"
         . "- Moves: Switches between Slot 1 AND Slot 2.`n"
         . "- Keybinds: Uses 'X', 'R' and 'F' for both slots.`n"
         . "- Ultimate: NO Ultimate used.`n`n"
         . "Recommended for: Maximizing normal damage without using Ult.", "Method 3 Info", 4096)
}

ShowInfo4(*) {
    ; 4096 = System Modal (Always On Top)
    MsgBox("METHOD 4 DETAILS:`n`n"
         . "- Speed: Slow / Full Rotation`n"
         . "- Moves: Switches between Slot 1 AND Slot 2.`n"
         . "- Keybinds: Uses 'X', 'R', 'F', and Ultimate ('C').`n"
         . "- Ultimate: YES, uses Ultimate (C) with animation wait.`n`n"
         . "Recommended for: Bosses or hard raids.", "Method 4 Info", 4096)
}

;===========================================
; METHOD & DOMAIN SWITCH LOGIC
;===========================================
MethodSwitch(*) {
    global ActiveMethod
    if (Radio2.Value)
        ActiveMethod := 2
    else if (Radio3.Value)
        ActiveMethod := 3
    else if (Radio4.Value)
        ActiveMethod := 4

    StatusText.Value := "Method " ActiveMethod " activated"
    MethodText.Value := "Active Method: " ActiveMethod
}

DomainToggle(*) {
    global UseDomain
    UseDomain := DomainCheck.Value
    if (UseDomain)
        StatusText.Value := "Domain (T) ENABLED"
    else
        StatusText.Value := "Domain (T) DISABLED"
}

;===========================================
; HELPER FUNCTION - CAST DOMAIN
;===========================================
CastDomain() {
    global UseDomain
    if (UseDomain) {
        ToolTip("Casting Domain (T)...")
        Send("t")
        Sleep(1200) ; Wait time for animation
        ToolTip()
    }
}

;===========================================
; HELPER FUNCTION - ROTATE AND SCAN (Q x2)
;===========================================
RotateAndScan() {
    ToolTip("Scanning Area (Rotate & Q)...")
    Loop 4 {
        Send("q")
        Sleep(550)
        Send("q")
        Sleep(550)
        Send("q")
        Sleep(550)
        
        Click("Right Down")
        Sleep(50)
        DllCall("mouse_event", "UInt", 0x0001, "Int", 250, "Int", 0, "UInt", 0, "UPtr", 0)
        Sleep(100)
        Click("Right Up")
        Sleep(250)
    }
    ToolTip()
}

;===========================================
; HELPER FUNCTION - CHECK FOR RETRY BUTTON
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
        ToolTip("Start found - Running...")

        RotateAndScan()

        ; === ATTACK SEQUENCE ===
        if (ActiveMethod = 2) {
            ; METHOD 2
            StatusText.Value := "Method 2: Looping until Retry found..."
            Loop {
                ToolTip("Method 2 - Attack Cycle " A_Index)
                Sleep(1000)
                
                CastDomain()

                Send("1")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(800)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(900)

                Sleep(800)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(900)
                Send("1")

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 3) {
            ; METHOD 3
            StatusText.Value := "Method 3: Looping until Retry found..."
            Loop {
                ToolTip("Method 3 - Double Attack Cycle " A_Index)

                ; Slot 1
                Sleep(1000)
                Send("1")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(800)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(900)

                Sleep(800)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(900)

                CastDomain()

                ; Slot 2
                Sleep(1000)
                Send("2")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(800)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(900)

                Sleep(800)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(900)

                if CheckForRetry()
                    break
                Sleep(1000)
            }

        } else if (ActiveMethod = 4) {
            ; METHOD 4
            StatusText.Value := "Method 4: Looping until Retry found..."
            Loop {
                ToolTip("Method 4 - Attack Cycle " A_Index)

                ; Slot 1
                Sleep(1000)
                Send("1")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(800)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(900)

                Sleep(800)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(900)

                Send("{c Down}")
                Sleep(1000)
                Send("{c Up}")
                Sleep(1500)

                CastDomain()

                ; Slot 2
                Sleep(1000)
                Send("2")
                Sleep(800)
                Send("{x Down}")
                Sleep(1000)
                Send("{x Up}")
                Sleep(1500)

                Sleep(800)
                Send("{r Down}")
                Sleep(1000)
                Send("{r Up}")
                Sleep(900)

                Sleep(800)
                Send("{f Down}")
                Sleep(1000)
                Send("{f Up}")
                Sleep(900)

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
F4:: {
    global ActiveMethod
    Radio2.Value := 1
    Radio3.Value := 0
    Radio4.Value := 0
    MethodSwitch()
}

F5:: {
    global ActiveMethod
    Radio2.Value := 0
    Radio3.Value := 1
    Radio4.Value := 0
    MethodSwitch()
}

F6:: {
    global ActiveMethod
    Radio2.Value := 0
    Radio3.Value := 0
    Radio4.Value := 1
    MethodSwitch()
}

F7:: {
    global ActiveMethod
    ; Cycle 2 -> 3 -> 4 -> 2
    if (ActiveMethod >= 4)
        ActiveMethod := 2
    else
        ActiveMethod := ActiveMethod + 1

    Radio2.Value := (ActiveMethod = 2)
    Radio3.Value := (ActiveMethod = 3)
    Radio4.Value := (ActiveMethod = 4)

    StatusText.Value := "Method " ActiveMethod " activated (Toggle)"
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

ESC:: ExitApp()