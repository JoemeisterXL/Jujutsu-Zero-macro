;===========================================
; ALL RAIDS MACRO - UNIFIED
;===========================================
#Requires AutoHotkey v2.0
#SingleInstance Force

SetWorkingDir(A_ScriptDir)
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")
SendMode("Event")
SetDefaultMouseSpeed(0)

; Reference Resolution
RefWidth := 1920
RefHeight := 1080
CurrentWidth := A_ScreenWidth
CurrentHeight := A_ScreenHeight
ScaleX := CurrentWidth / RefWidth
ScaleY := CurrentHeight / RefHeight

;--- Global Variables ---
global ActiveMethod := 1
global RunCount := 0
global ActiveMethod := 1
global RunCount := 0
global StartTime := 0
global IsRunning := false
global RetryFound := false
global DomainUsed := false
global LastToolTipText := ""
global LastToolTipTime := 0

;===========================================
; CREATE GUI
;===========================================
MainGui := Gui("+AlwaysOnTop", "All Raids Macro v1.0")
MainGui.BackColor := "1a1a1a"
MainGui.SetFont("s10 cWhite", "Segoe UI")

MainGui.Add("Text", "x20 y15 w300 Center", "=== ALL RAIDS MACRO ===")

;--- Statistics Group ---
MainGui.Add("GroupBox", "x20 y45 w300 h80", "Statistics")
MainGui.SetFont("s11 Bold cLime")
RunCountText := MainGui.Add("Text", "x40 y65 w260 Center", "Runs: 0")
TimerText := MainGui.Add("Text", "x40 y85 w260 Center", "Time: 00:00:00")
MainGui.SetFont("s10 norm cWhite")

;--- Method Selection Group ---
MainGui.Add("GroupBox", "x20 y135 w300 h160", "Method Selection")
Radio1 := MainGui.Add("Radio", "x40 y155 w260 vMethodRadio1 Checked", "Method 1: Slot 1 Only (Fast | No Ult)")
Radio2 := MainGui.Add("Radio", "x40 y185 w260 vMethodRadio2", "Method 2: Slot 1+2 (No Ult)")
Radio3 := MainGui.Add("Radio", "x40 y215 w260 vMethodRadio3", "Method 3: Slot 1+2 + Ult (C)")

Radio1.OnEvent("Click", MethodSwitch)
Radio2.OnEvent("Click", MethodSwitch)
Radio3.OnEvent("Click", MethodSwitch)

;--- Options Group ---
MainGui.Add("GroupBox", "x20 y300 w300 h125", "Options")
MainGui.SetFont("s10 Bold cYellow")
DomainCheck := MainGui.Add("Checkbox", "x40 y320 w260 vDomainEnabled", "Enable Domain (T) - 10s delay")
MainGui.SetFont("s10 Bold c00ccff")
KashimoCheck := MainGui.Add("Checkbox", "x40 y355 w260 vKashimoEnabled", "Kashimo Boss(Lvl.1250) (Activated if you do that Boss)")
MainGui.SetFont("s10 Bold caa00ff")
MakiCheck := MainGui.Add("Checkbox", "x40 y390 w260 vMakiEnabled", "Maki Boss(Lvl.900) (Activated if you do that Boss)")
MainGui.SetFont("s10 norm cWhite")

; Info Text
MainGui.SetFont("s9 Bold cYellow")
MethodText := MainGui.Add("Text", "x40 y270 w260", "Active Method: 1")
MainGui.SetFont("s10 norm cWhite")

;--- Controls Group ---
MainGui.Add("GroupBox", "x20 y440 w300 h110", "Controls")
MainGui.Add("Text", "x40 y460 w260", "F1 = Start Macro")
MainGui.Add("Text", "x40 y480 w260", "F2 = Stop / Reload")
MainGui.Add("Text", "x40 y500 w260", "F3/F4/F5 = Quick Switch Method")
MainGui.Add("Text", "x40 y520 w260", "F7 = Toggle | ESC = Close")

;--- Status Group ---
MainGui.Add("GroupBox", "x20 y560 w300 h50", "Status")
StatusText := MainGui.Add("Text", "x40 y578 w260 cLime", "Ready - " CurrentWidth "x" CurrentHeight)

MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.Show("w340 h630")

;===========================================
; TIMER UPDATE
;===========================================
UpdateTimer() {
    global StartTime, IsRunning, TimerText
    if (!IsRunning)
        return
    ElapsedSeconds := (A_TickCount - StartTime) // 1000
    Hours := ElapsedSeconds // 3600
    Minutes := Mod(ElapsedSeconds // 60, 60)
    Seconds := Mod(ElapsedSeconds, 60)
    TimerText.Value := "Time: " Format("{:02d}:{:02d}:{:02d}", Hours, Minutes, Seconds)
}
SetTimer(UpdateTimer, 1000)

;===========================================
; BACKGROUND RETRY CHECKER & WATCHDOG
; Runs every 2s
;===========================================
BackgroundRetryCheck() {
    global RetryFound, RunCount, RunCountText, LastToolTipTime

    ; -- Watchdog Check --
    if (LastToolTipTime > 0 && A_TickCount - LastToolTipTime > 25000) {
        StatusText.Value := "⚠️ Timeout! Restarting macro..."
        Sleep(1000)
        Send("{F2}") ; Force reload
        return
    }

    if (RetryFound)
        return
    if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*60 retry.png") {
        RetryFound := true
        MouseMove(FoundX, FoundY, 5)
        Sleep(300)
        Click(4)
        Sleep(500)
        MouseMove(FoundX + 3, FoundY + 3, 5)
        Sleep(300)
        Click()
        RunCount++
        RunCountText.Value := "Runs: " RunCount
        StatusText.Value := "Run #" RunCount " completed!"
    }
}

;===========================================
; CUSTOM TOOLTIP WRAPPER
;===========================================
CustomToolTip(text:="") {
    global LastToolTipText, LastToolTipTime
    if (text != LastToolTipText) {
        LastToolTipTime := text ? A_TickCount : 0
        LastToolTipText := text
        ToolTip(text)
    }
}

;===========================================
; METHOD SWITCH
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
; ROTATE CAMERA & TARGET (ULTRA FAST)
;===========================================
RotateCameraAndTarget() {
    Click("Right Down")
    Sleep(15)
    DllCall("mouse_event", "UInt", 0x0001, "Int", 370, "Int", 0, "UInt", 0, "UPtr", 0)
    Sleep(15)

    if (KashimoCheck.Value = 1 || MakiCheck.Value = 1)
        Send("{Space}")

    Click("Right Up")
    Sleep(25)
    MouseMove(A_ScreenWidth / 2, A_ScreenHeight / 2, 0)
    Sleep(25)

    if (KashimoCheck.Value = 1 || MakiCheck.Value = 1)
        Send("{Space}")

    Send("{z Down}")
    Sleep(25)
    Send("{z Up}")
    Sleep(25)

    if (KashimoCheck.Value = 1 || MakiCheck.Value = 1)
        Send("{Space}")

    Send("{y Down}")
    Sleep(25)
    Send("{y Up}")
    Sleep(25)

    if (KashimoCheck.Value = 1 || MakiCheck.Value = 1)
        Send("{Space}")

    Send("{z Down}")
    Sleep(25)
    Send("{z Up}")
    Sleep(40)
}

;===========================================
; FULL CAMERA SCAN (4 rotations)
;===========================================
FullCameraScan() {
    CustomToolTip("Scanning...")
    StatusText.Value := "◎ Scanning..."
    Loop 4 {
        RotateCameraAndTarget()
        Sleep(150)
    }
    Click("Middle")
    CustomToolTip()
}

;===========================================
; DOMAIN EXPANSION
;===========================================
PerformDomain() {
    if (DomainCheck.Value = 1) {
        global DomainUsed
        if (!DomainUsed) {
            CustomToolTip("Domain in 10s...")
            StatusText.Value := "Waiting 10s for Domain..."
            Sleep(10000)
            Send("{t Down}")
            Sleep(800)
            Send("{t Up}")
            Sleep(2000)
            DomainUsed := true
            CustomToolTip()
        }
    }
}

;===========================================
; MAIN LOOP - F1 TO START
;===========================================
F1:: {
    global ActiveMethod, StartTime, IsRunning, RetryFound, DomainUsed

    if (!IsRunning) {
        StartTime := A_TickCount
        IsRunning := true
    }

    StatusText.Value := "Macro running... (Method " ActiveMethod ")"

    Loop {
        CustomToolTip("Waiting for 'start.png'...")

        ; Wait for start image
        Loop {
            if ImageSearch(&StartX, &StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*50 " . A_ScriptDir . "\start.png")
                break
            Sleep(2000)
        }

        CustomToolTip("Executing Method " ActiveMethod)
        StatusText.Value := "Start found - Running..."

        ; Reset flags
        RetryFound := false
        DomainUsed := false

        ; Camera scan at start
        FullCameraScan()

        ; START background retry checker (every 2 seconds)
        SetTimer(BackgroundRetryCheck, 2000)

        ; === ATTACK SEQUENCE ===
        if (ActiveMethod = 1) {
            ; METHOD 1: Fast - Slot 1 only
            StatusText.Value := "Method 1 running..."
            Loop {
                if (RetryFound)
                    break
                CustomToolTip("M1 - Cycle " A_Index)
                RotateCameraAndTarget()

                Send("1")
                Sleep(400)
                Send("{x Down}")
                Sleep(500)
                Send("{x Up}")
                Sleep(300)

                if (RetryFound)
                    break

                Send("{r Down}")
                Sleep(500)
                Send("{r Up}")
                Sleep(300)

                if (RetryFound)
                    break

                Send("{f Down}")
                Sleep(500)
                Send("{f Up}")
                Sleep(300)
                Send("1")

                ; Domain check
                PerformDomain()

                if (RetryFound)
                    break
                Sleep(500)
            }

        } else if (ActiveMethod = 2) {
            ; METHOD 2: Slot 1 + Slot 2 (No Ult)
            StatusText.Value := "Method 2 running..."
            Loop {
                if (RetryFound)
                    break
                CustomToolTip("M2 - Cycle " A_Index)
                RotateCameraAndTarget()

                ; Slot 1
                Send("1")
                Sleep(400)
                Send("{x Down}")
                Sleep(500)
                Send("{x Up}")
                Sleep(300)

                Send("{r Down}")
                Sleep(500)
                Send("{r Up}")
                Sleep(300)

                Send("{f Down}")
                Sleep(500)
                Send("{f Up}")
                Sleep(300)

                if (RetryFound)
                    break

                ; Rotate between slots
                RotateCameraAndTarget()

                ; Slot 2
                Send("2")
                Sleep(400)
                Send("{x Down}")
                Sleep(500)
                Send("{x Up}")
                Sleep(300)

                Send("{r Down}")
                Sleep(500)
                Send("{r Up}")
                Sleep(300)

                Send("{f Down}")
                Sleep(500)
                Send("{f Up}")
                Sleep(300)

                ; Domain check
                PerformDomain()

                if (RetryFound)
                    break
                Sleep(500)
            }

        } else if (ActiveMethod = 3) {
            ; METHOD 3: Slot 1 + Slot 2 + Ult (C)
            StatusText.Value := "Method 3 running..."
            Loop {
                if (RetryFound)
                    break
                CustomToolTip("M3 - Cycle " A_Index)
                RotateCameraAndTarget()

                ; Slot 1
                Send("1")
                Sleep(400)
                Send("{x Down}")
                Sleep(500)
                Send("{x Up}")
                Sleep(300)

                Send("{r Down}")
                Sleep(500)
                Send("{r Up}")
                Sleep(300)

                Send("{f Down}")
                Sleep(500)
                Send("{f Up}")
                Sleep(300)

                Send("{c Down}")
                Sleep(500)
                Send("{c Up}")
                Sleep(300)

                if (RetryFound)
                    break

                ; Rotate between slots
                RotateCameraAndTarget()

                ; Slot 2
                Send("2")
                Sleep(400)
                Send("{x Down}")
                Sleep(500)
                Send("{x Up}")
                Sleep(300)

                Send("{r Down}")
                Sleep(500)
                Send("{r Up}")
                Sleep(300)

                Send("{f Down}")
                Sleep(500)
                Send("{f Up}")
                Sleep(300)

                ; Domain check
                PerformDomain()

                if (RetryFound)
                    break
                Sleep(500)
            }
        }

        ; STOP background retry checker
        SetTimer(BackgroundRetryCheck, 0)
        CustomToolTip()

        StatusText.Value := "Cycle done - Waiting 15s..."
        Sleep(15000)
    }
}

;===========================================
; HOTKEYS
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
    ActiveMethod := Mod(ActiveMethod, 3) + 1
    Radio1.Value := (ActiveMethod = 1)
    Radio2.Value := (ActiveMethod = 2)
    Radio3.Value := (ActiveMethod = 3)
    StatusText.Value := "Method " ActiveMethod " activated (Toggle)"
    MethodText.Value := "Active Method: " ActiveMethod
}

;===========================================
; STOP / EXIT
;===========================================
F2:: {
    global IsRunning, RunCount, StartTime
    SetTimer(BackgroundRetryCheck, 0)
    IsRunning := false
    RunCount := 0
    StartTime := 0
    StatusText.Value := "Macro reloaded!"
    Reload()
}

ESC:: ExitApp()
