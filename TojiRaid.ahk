;===========================================
; CONFIGURATION
;===========================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"
SetDefaultMouseSpeed 0

; --- Reference Resolution ---
RefWidth := 1920
RefHeight := 1080

; --- User Fine Tuning ---
UserOffsetX := 0
UserOffsetY := 0

; --- Globals ---
ActiveMethod := 1
RobloxWindowID := 0
OverlayCreated := false
MacroRunning := false

; --- Statistics ---
RunCounter := 0
StartTime := 0
TimerActive := false
global ORunCounter := ""
global ORunTime := ""

; === ADJUSTABLE VALUES ===
TargetWidth := 800 ; Roblox Window Width
TargetHeight := 630 ; Roblox Window Height

; Window Offset Adjustment (if Roblox is shifted)
WindowOffsetX := -180 ; Negative = left, Positive = right
WindowOffsetY := 0 ; Negative = up, Positive = down

;===========================================
; START GUI
;===========================================
MainGui := Gui("+AlwaysOnTop", "Raid Macro v3.0")
MainGui.BackColor := "0x1e1e1e"
MainGui.SetFont("s11 cWhite Bold", "Segoe UI")
MainGui.Add("Text", "x20 y15 w360 Center", "=== RAID MACRO CONTROLLER ===")

MainGui.SetFont("s10 cWhite Norm")
MainGui.Add("GroupBox", "x20 y50 w360 h120", "Method Selection")
Method1Radio := MainGui.Add("Radio", "x40 y75 w320 Checked", "Method 1: Slot 1")
Method1Radio.OnEvent("Click", (*) => MethodSwitch())
Method2Radio := MainGui.Add("Radio", "x40 y105 w320", "Method 2: Slot 1 + 2")
Method2Radio.OnEvent("Click", (*) => MethodSwitch())

MainGui.SetFont("s9 Bold c0x00FF7F")
MethodText := MainGui.Add("Text", "x40 y140 w320", "Active Method: 1")

MainGui.SetFont("s10 cWhite Norm")
MainGui.Add("GroupBox", "x20 y180 w360 h140", "Controls")
MainGui.Add("Text", "x40 y205 w320", "F1 = Start")
MainGui.Add("Text", "x40 y230 w320", "F2 = Stop / Reload")
MainGui.Add("Text", "x40 y255 w320", "F3 = Create Overlay")
MainGui.Add("Text", "x40 y280 w320", "F6 = Reset Window")
MainGui.Add("Text", "x40 y295 w320", "ESC = Exit")

MainGui.Add("GroupBox", "x20 y330 w360 h80", "Status")
StatusText := MainGui.Add("Text", "x40 y355 w320 cLime", "Ready - Press F3!")

MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.Show("w400 h430")

;===========================================
; METHOD SWITCH
;===========================================
MethodSwitch() {
    global ActiveMethod, MethodText, StatusText
    ActiveMethod := Method1Radio.Value ? 1 : 2
    MethodText.Value := "Active Method: " ActiveMethod
    StatusText.Value := "Method " ActiveMethod " active"
}

;===========================================
; CREATE OVERLAY & RESIZE ROBLOX
;===========================================
F3:: {
    global RobloxWindowID, OverlayCreated, TargetWidth, TargetHeight, MainGui, WindowOffsetX, WindowOffsetY

    ; --- FINE TUNING: MOVE ROBLOX WITHIN OVERLAY ---
    RobloxInnerShiftX := -8 ; Positive = right, Negative = left
    RobloxInnerShiftY := 0 ; Positive = down, Negative = up
    ; -------------------------------------------------------------

    if (OverlayCreated)
        return

    try {
        RobloxWindowID := WinGetID("ahk_exe RobloxPlayerBeta.exe")
    } catch {
        MsgBox "Roblox not found!", "Error", 16
        return
    }

    ; Calculate base position (center + your global offset)
    BaseX := ((A_ScreenWidth - TargetWidth) / 2) + WindowOffsetX
    BaseY := ((A_ScreenHeight - TargetHeight) / 2) + WindowOffsetY 

    ; Move Roblox with additional "InnerShift"
    WinMove BaseX + RobloxInnerShiftX, BaseY + RobloxInnerShiftY, TargetWidth, TargetHeight, "ahk_id " RobloxWindowID
    WinSetAlwaysOnTop true, "ahk_id " RobloxWindowID

    MainGui.Hide()

    ; Overlay is set to base position (stays fixed)
    CreateOverlayMenu(BaseX, BaseY) 
    OverlayCreated := true
}

;===========================================
; MODERN OVERLAY
;===========================================
CreateOverlayMenu(rX, rY) {
    global ActiveMethod, TargetWidth, TargetHeight, OverlayGui, OMethod1, OMethod2, OStatusText
    global ORunCounter, ORunTime

    ; Asymmetric Borders: Large left, small right
    LeftBorder := 280 ; More space for controls
    RightBorder := 30 ; Minimal border on right
    TopBorder := 15
    BottomBorder := 15

    OW := LeftBorder + TargetWidth + RightBorder
    OH := TopBorder + TargetHeight + BottomBorder

    ; Create overlay with modern design
    OverlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20", "Overlay")
    OverlayGui.BackColor := "0x1a1a2e" ; Dark blue-gray instead of black

    ; No transparency - solid background

    ; Region with asymmetric cutout
    RegionStr := "0-0 " OW "-0 " OW "-" OH " 0-" OH " 0-0 " LeftBorder "-" TopBorder " " (LeftBorder+TargetWidth) "-" TopBorder " " (LeftBorder+TargetWidth) "-" (TopBorder+TargetHeight) " " LeftBorder "-" (TopBorder+TargetHeight) " " LeftBorder "-" TopBorder
    WinSetRegion RegionStr, OverlayGui.Hwnd

    ; === HEADER AREA (left only) ===
    HeaderBox := OverlayGui.Add("Text", "x0 y0 w" LeftBorder " h80 Background0x0f3460")

    ; Title
    OverlayGui.SetFont("s14 c0x00d9ff Bold", "Segoe UI")
    OverlayGui.Add("Text", "x0 y20 w" LeftBorder " Center BackgroundTrans", "⚡ RAID MACRO")

    OverlayGui.SetFont("s9 c0x4a90e2", "Segoe UI")
    OverlayGui.Add("Text", "x0 y45 w" LeftBorder " Center BackgroundTrans", "━━━━━━━━━━━━━━")

    ; === CONTROL PANEL ===
    PanelX := 15
    PanelY := 95
    PanelW := 250

    ; Method Selection Box with modern border (Box first)
    MethodBox := OverlayGui.Add("Text", "x" PanelX " y" PanelY " w" PanelW " h110 Background0x16213e")

    OverlayGui.SetFont("s10 c0x00d9ff Bold", "Segoe UI")
    OverlayGui.Add("Text", "x" (PanelX+10) " y" (PanelY+8) " BackgroundTrans", "⚙ METHOD SELECTION")

    ; Radio Buttons with better styling (Buttons after)
    OverlayGui.SetFont("s9 cWhite", "Segoe UI")
    OMethod1 := OverlayGui.Add("Radio", "x" (PanelX+15) " y" (PanelY+35) " w190 " (ActiveMethod=1?"Checked":""), "🎯 Method 1: Single Strike")
    OMethod1.OnEvent("Click", (*) => OMethodSwitch())

    OMethod2 := OverlayGui.Add("Radio", "x" (PanelX+15) " y" (PanelY+62) " w190 " (ActiveMethod=2?"Checked":""), "⚔ Method 2: Double Attack")
    OMethod2.OnEvent("Click", (*) => OMethodSwitch())

    ; === STATUS AREA ===
    StatusY := PanelY + 125
    StatusBox := OverlayGui.Add("Text", "x" PanelX " y" StatusY " w" PanelW " h70 Background0x16213e")

    OverlayGui.SetFont("s9 c0x00d9ff Bold", "Segoe UI")
    OverlayGui.Add("Text", "x" (PanelX+10) " y" (StatusY+8) " BackgroundTrans", "📊 STATUS")

    OverlayGui.SetFont("s9 c0x4ade80", "Segoe UI")
    OStatusText := OverlayGui.Add("Text", "x" (PanelX+15) " y" (StatusY+32) " w" (PanelW-20) " BackgroundTrans", "✓ Ready to start")

    ; === HOTKEYS INFO ===
    HotkeyY := StatusY + 85
    HotkeyBox := OverlayGui.Add("Text", "x" PanelX " y" HotkeyY " w" PanelW " h95 Background0x16213e")

    OverlayGui.SetFont("s9 c0x00d9ff Bold", "Segoe UI")
    OverlayGui.Add("Text", "x" (PanelX+10) " y" (HotkeyY+8) " BackgroundTrans", "⌨ CONTROLS")

    OverlayGui.SetFont("s8 cWhite", "Segoe UI")
    OverlayGui.Add("Text", "x" (PanelX+15) " y" (HotkeyY+30) " BackgroundTrans", "F1 ▸ Start Macro")
    OverlayGui.Add("Text", "x" (PanelX+15) " y" (HotkeyY+48) " BackgroundTrans", "F2 ▸ Stop/Reload")
    OverlayGui.Add("Text", "x" (PanelX+15) " y" (HotkeyY+66) " BackgroundTrans", "F6 ▸ Reset Window")

    ; === STATISTICS AREA (NEW) ===
    StatsY := HotkeyY + 110
    StatsBox := OverlayGui.Add("Text", "x" PanelX " y" StatsY " w" PanelW " h85 Background0x16213e")

    OverlayGui.SetFont("s9 c0x00d9ff Bold", "Segoe UI")
    OverlayGui.Add("Text", "x" (PanelX+10) " y" (StatsY+8) " BackgroundTrans", "📈 STATISTICS")

    OverlayGui.SetFont("s9 c0xffa500", "Segoe UI")
    OverlayGui.Add("Text", "x" (PanelX+15) " y" (StatsY+32) " BackgroundTrans", "Runs:")
    ORunCounter := OverlayGui.Add("Text", "x" (PanelX+80) " y" (StatsY+32) " w150 cWhite BackgroundTrans", "0")

    OverlayGui.Add("Text", "x" (PanelX+15) " y" (StatsY+54) " BackgroundTrans", "Runtime:")
    ORunTime := OverlayGui.Add("Text", "x" (PanelX+80) " y" (StatsY+54) " w150 cWhite BackgroundTrans", "00:00:00")

    ; === FOOTER ===
    FooterY := OH - 25
    OverlayGui.SetFont("s7 c0x4a90e2", "Segoe UI")
    OverlayGui.Add("Text", "x0 y" FooterY " w" LeftBorder " Center BackgroundTrans", "Raid Macro v3.0 • F6 = Reset")

    ; Show overlay (move Roblox to the right)
    OverlayGui.Show("x" (rX-LeftBorder) " y" (rY-TopBorder) " w" OW " h" OH " NA")
}

; Update for better status feedback
OMethodSwitch() {
    global ActiveMethod, OMethod1, OStatusText
    ActiveMethod := OMethod1.Value ? 1 : 2

    ; Animated status change
    OStatusText.SetFont("c0xffd700") ; Gold for change
    OStatusText.Value := "⚡ Method " ActiveMethod " activated!"

    ; Back to green after 1.5 seconds
    SetTimer () => (OStatusText.SetFont("c0x4ade80"), OStatusText.Value := "✓ Ready to start"), -1500
}

; Timer Update Function
UpdateTimer() {
    global StartTime, ORunTime, TimerActive
    if (!TimerActive)
        return

    ElapsedSeconds := (A_TickCount - StartTime) // 1000
    Hours := ElapsedSeconds // 3600
    Minutes := Mod(ElapsedSeconds // 60, 60)
    Seconds := Mod(ElapsedSeconds, 60)

    TimeStr := Format("{:02}:{:02}:{:02}", Hours, Minutes, Seconds)
    try ORunTime.Value := TimeStr
}

; Run Counter Update
UpdateRunCounter() {
    global RunCounter, ORunCounter
    try ORunCounter.Value := RunCounter
}

;===========================================
; ROBLOX CLIENT AREA
;===========================================
GetRobloxArea(&x, &y, &w, &h) {
    global RobloxWindowID
    if WinExist("ahk_id " RobloxWindowID) {
        WinGetPos(&outX, &outY, &outW, &outH, "ahk_id " RobloxWindowID)
        x := outX
        y := outY
        w := outW
        h := outH
    }
}

;===========================================
; MACRO LOOP
;===========================================
F1:: {
    global MacroRunning, ActiveMethod, RobloxWindowID, OverlayCreated, StatusText, OStatusText
    global RefWidth, RefHeight, UserOffsetX, UserOffsetY
    global RunCounter, StartTime, TimerActive

    MacroRunning := true

    ; Start timer on first start
    if (StartTime = 0) {
        StartTime := A_TickCount
        TimerActive := true
        SetTimer UpdateTimer, 1000
    }

    UpdateStatus(txt) {
        ToolTip(txt)
        if (OverlayCreated)
            OStatusText.Value := txt
        else
            StatusText.Value := txt
    }

    UpdateStatus("Macro running... (Method " ActiveMethod ")")

    Loop {
        if (!MacroRunning)
            break

        ; Get current window data
        GetRobloxArea(&RX, &RY, &RW, &RH)
        ScaleX := RW / RefWidth
        ScaleY := RH / RefHeight

        ; Target position for rewards (Target 2)
        T2X := RX + (50 * ScaleX)
        T2Y := RY + (240 * ScaleY)

        T3X := RX + (661 * ScaleX)
        T3Y := RY + (192 * ScaleY)

        ; --- STEP 1: START IMAGE SEARCH ---
        UpdateStatus('Waiting for "start.png"...')
        Loop {
            if (!MacroRunning)
                break 2
            if (ImageSearch(&sx, &sy, 0, 0, A_ScreenWidth, A_ScreenHeight, "*50 start.png"))
                break
            Sleep 2000
        }

        UpdateStatus("Start found - Running...")

        ; --- STEP 2: CAMERA ROTATION & TOJI SEARCH ---
        FoundBlue := false
        Loop 20 {
            if (!MacroRunning)
                break 2

            CurrentAttempt := A_Index
            UpdateStatus("Searching Toji.png (" CurrentAttempt "/20)...")

            SearchStartTime := A_TickCount
            Loop {
                if (!MacroRunning)
                    break 2

                if (ImageSearch(&bx, &by, 0, 0, A_ScreenWidth, A_ScreenHeight, "*70 Toji.png")) {
                    UpdateStatus("Toji.png found! Clicking...")
                    FoundBlue := true
                    MouseMove bx, by, 5
                    Sleep 300
                    Click
                    Sleep 500
                    break 2
                }

                if (A_TickCount - SearchStartTime > 4000)
                    break

                Sleep 200
            }

            if (FoundBlue)
                break

            UpdateStatus("Toji not found - Rotating camera...")
            Click "Right Down"
            Sleep 100
            DllCall("mouse_event", "UInt", 0x0001, "Int", 185, "Int", 0, "UInt", 0, "UPtr", 0)
            Sleep 200
            Click "Right Up"

            MouseMove (A_ScreenWidth / 2), (A_ScreenHeight / 2), 0
            Sleep 2000
        }

        if (!FoundBlue) {
            UpdateStatus("WARNING: Toji not found!")
            Sleep 2000
        }

        ToolTip()

        ; --- STEP 3: ATTACK SEQUENCE ---
        UpdateStatus("Executing Method " ActiveMethod)

        Sleep 2000
        Send "1"
        Sleep 800
        Send "{c Down}"
        Sleep 800
        Send "{c Up}"

        if (ActiveMethod = 1) {
            Sleep 7000
        } else if (ActiveMethod = 2) {
            Sleep 9000
            UpdateStatus("Method 2: Slot 2 Attack")
            Send "2"
            Sleep 800
            Send "{c Down}"
            Sleep 800
            Send "{c Up}"
            Sleep 9000
        }

        ; --- STEP 4: SKIP REWARDS (Target 2) ---
        UpdateStatus("Skipping rewards...")
        Sleep 4000
        MouseMove T2X, T2Y
        Loop 4 {
            Click
            Sleep 500
        }

        UpdateStatus("Clicking Retry button")
        MouseMove T3X, T3Y, 5 
        Sleep 300 
        Click "Down" 
        Sleep 150 
        Click "Up"

        ; Increase run counter
        RunCounter++
        UpdateRunCounter()
        UpdateStatus("Run " RunCounter " completed!")

        Sleep 15000
    }

    UpdateStatus("Stopped")
    ToolTip()
}

;===========================================
; STOP
;===========================================
F2:: {
    global MacroRunning, TimerActive
    MacroRunning := false
    TimerActive := false
    Sleep 500
    Reload
}

;===========================================
; RESET
;===========================================
F6:: {
    global OverlayCreated, RobloxWindowID, OverlayGui, MainGui, MacroRunning
    global TimerActive, RunCounter, StartTime

    MacroRunning := false
    TimerActive := false
    RunCounter := 0
    StartTime := 0

    if (OverlayCreated) {
        try OverlayGui.Destroy()
        OverlayCreated := false
    }

    if (RobloxWindowID) {
        WinSetAlwaysOnTop false, "ahk_id " RobloxWindowID
        WinMaximize "ahk_id " RobloxWindowID
    }

    MainGui.Show()
}

;===========================================
; EXIT
;===========================================
ESC::ExitApp()