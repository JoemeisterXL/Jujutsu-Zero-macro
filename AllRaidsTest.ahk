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
global AudioThreshold := 0.06  ; Default audio threshold (0.0 - 1.0)
global EnemyDetected := false
global DeathFound := false
global GlobalSlotA := "1"
global GlobalSlotB := "2"
global LockRobloxWindow := false
global InfoGui := ""
global GlobalSelectedBoss := IniRead(A_ScriptDir . "\settings.ini", "Options", "Boss", "Awakened Lightning")

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

;--- Guide Button ---
MainGui.SetFont("s10 Bold cYellow")
GuideBtn := MainGui.Add("Button", "x20 y135 w300 h35", "📖 Guide anzeigen")
GuideBtn.OnEvent("Click", ShowGuide)
MainGui.SetFont("s10 cWhite")

;--- Method Selection Group ---
MainGui.Add("GroupBox", "x20 y175 w300 h160", "Method Selection")
Radio1 := MainGui.Add("Radio", "x40 y195 w260 vMethodRadio1 Checked", "Method 1: Slot 1 Only (Fast | No Ult)")
Radio2 := MainGui.Add("Radio", "x40 y225 w260 vMethodRadio2", "Method 2: Slot 1+2 (No Ult)")
Radio3 := MainGui.Add("Radio", "x40 y255 w260 vMethodRadio3", "Method 3: Slot 1+2 + Ult (C)")

Radio1.OnEvent("Click", MethodSwitch)
Radio2.OnEvent("Click", MethodSwitch)
Radio3.OnEvent("Click", MethodSwitch)

;--- Options Group ---
MainGui.Add("GroupBox", "x20 y340 w300 h195", "Options")
MainGui.SetFont("s10 Bold cYellow")
DomainCheck := MainGui.Add("Checkbox", "x40 y360 w260 vDomainEnabled", "Enable Domain (T) - 10s delay")
MainGui.SetFont("s10 Bold c00ccff")
MainGui.Add("Text", "x40 y390 w260", "Select Boss:")
BossList := ["Awakened Lightning", "Disaster Flame Curse", "Sorcerer Killer", "King of Curses", "God of Lightning",
    "Awakened Zen'in"]
BossDrop := MainGui.Add("DropDownList", "x40 y410 w220 vSelectedBoss", BossList)
BossDrop.Text := GlobalSelectedBoss
if (BossDrop.Text = "")
    BossDrop.Choose(1)
BossDrop.OnEvent("Change", BossDropdownChange)

MainGui.SetFont("s10 Bold cff00ff")
OnetapCheck := MainGui.Add("Checkbox", "x40 y438 w75 vOnetapEnabled", "onetap")
OnetapInfoBtn := MainGui.Add("Button", "x120 y435 w25 h25", "?")
OnetapInfoBtn.OnEvent("Click", ShowOnetapInfo)
if (GlobalSelectedBoss == "Awakened Lightning") {
    OnetapCheck.Visible := false
    OnetapInfoBtn.Visible := false
}

MainGui.SetFont("s10 Bold c00ff99")
LockCheck := MainGui.Add("Checkbox", "x40 y460 w260 vLockEnabled", "Lock Roblox Window (800x600)")
LockCheck.OnEvent("Click", LockCheckChange)
MainGui.SetFont("s9 Bold cff6600")
MainGui.Add("Text", "x40 y485 w160", "Audio Threshold:")
AudioSlider := MainGui.Add("Slider", "x40 y505 w200 vAudioSlider Range1-100", 6)
AudioSliderText := MainGui.Add("Text", "x245 y505 w70 cff6600", "0.06")
AudioSlider.OnEvent("Change", AudioSliderChange)
MainGui.SetFont("s10 norm cWhite")

; Info Text
MainGui.SetFont("s9 Bold cYellow")
MethodText := MainGui.Add("Text", "x40 y310 w260", "Active Method: 1")
MainGui.SetFont("s10 norm cWhite")

;--- Controls Group ---
MainGui.Add("GroupBox", "x20 y550 w300 h110", "Controls")
MainGui.Add("Text", "x40 y570 w260", "F1 = Start Macro")
MainGui.Add("Text", "x40 y590 w260", "F2 = Stop / Reload")
MainGui.Add("Text", "x40 y610 w260", "F3/F4/F5 = Quick Switch Method")
MainGui.Add("Text", "x40 y630 w260", "F7 = Toggle | ESC = Close")

;--- Status Group ---
MainGui.Add("GroupBox", "x20 y670 w300 h50", "Status")
StatusText := MainGui.Add("Text", "x40 y688 w260 cLime", "Ready - " CurrentWidth "x" CurrentHeight)

MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.Show("w340 h750 x800 y0")

;===========================================
; LOCK ROBLOX WINDOW
;===========================================
LockCheckChange(*) {
    global LockRobloxWindow
    if (LockCheck.Value = 1) {
        LockRobloxWindow := true
        ; Move immediately and start timer
        if WinExist("Roblox")
            WinMove(0, 0, 800, 600, "Roblox")
        SetTimer(KeepRobloxLocked, 100)
        StatusText.Value := "🔒 Roblox window locked"
    } else {
        LockRobloxWindow := false
        SetTimer(KeepRobloxLocked, 0)
        StatusText.Value := "🔓 Roblox window unlocked"
    }
}

KeepRobloxLocked() {
    if WinExist("Roblox")
        WinMove(0, 0, 800, 600, "Roblox")
}

BossDropdownChange(Ctrl, *) {
    global GlobalSelectedBoss
    GlobalSelectedBoss := Ctrl.Text
    IniWrite(GlobalSelectedBoss, A_ScriptDir . "\settings.ini", "Options", "Boss")

    if (GlobalSelectedBoss != "Awakened Lightning") {
        OnetapCheck.Visible := true
        OnetapInfoBtn.Visible := true
    } else {
        OnetapCheck.Visible := false
        OnetapInfoBtn.Visible := false
        OnetapCheck.Value := 0
    }
}

ShowOnetapInfo(*) {
    global GlobalSelectedBoss, InfoGui
    if (InfoGui) {
        try InfoGui.Destroy()
    }

    imgPath := A_ScriptDir "\onetap_positions\" GlobalSelectedBoss ".png"
    if !FileExist(imgPath)
        imgPath := A_ScriptDir "\onetap_positions\" GlobalSelectedBoss ".jpg"

    if !FileExist(imgPath) {
        MsgBox("Kein Bild gefunden! `nEs fehlt: " imgPath, "Bild fehlt", 16)
        return
    }

    InfoGui := Gui("+ToolWindow +AlwaysOnTop", "Position: " GlobalSelectedBoss)
    InfoGui.Add("Picture", "w600 h-1", imgPath) ; w600 scales the image proportionally
    InfoGui.Show("NoActivate")
}

ShowGuide(*) {
    guideText := "=== ALL RAIDS MACRO GUIDE ===`n`n"
    guideText .= "1. Roblox Settings -> Graphics 5, Camera Sensitivity 0,52.`n"
    guideText .= "2. Ingame Settings -> All on default.`n"
    guideText .= "3. Choose a Methode you prefer.`n"
    guideText .= "4. Choose a Boss in the Dropdown menu.`n"
    guideText .= "5. Activate onetap if you can kill the Boss very fast (Best would be to onehit the Boss).`n"
    guideText .= "   to onetap the boss you need the right placement (use the ? button to see the positions).`n"
    guideText .= "6. If you are in the Boss fight you can click F1 to start.`n"
    guideText .= "   Audio Threshold is not used right now just ignore it.`n"
    guideText .= "7. If you click F2 you can stop the macro and reload it."
    guideText .= "Info: dont go into the Fullscreen mode, turn it off!"

    MsgBox(guideText, "Info / Guide", 64)
}

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
    global RetryFound, RunCount, RunCountText, LastToolTipTime, DeathFound, GlobalSlotA, GlobalSlotB

    ; -- Watchdog Check --
    if (LastToolTipTime > 0 && A_TickCount - LastToolTipTime > 25000) {
        StatusText.Value := "⚠️ Timeout! Restarting macro..."
        Sleep(1000)
        Send("{F2}") ; Force reload
        return
    }

    if (RetryFound || DeathFound)
        return

    if WinExist("Roblox")
        WinGetPos(&WinX, &WinY, &WinW, &WinH, "Roblox")
    else {
        WinX := 0, WinY := 0, WinW := A_ScreenWidth, WinH := A_ScreenHeight
    }

    ; Check for retry button (win/loss screen)
    if ImageSearch(&FoundX, &FoundY, WinX, WinY, WinX + WinW, WinY + WinH, "*60 retry.png") {
        RetryFound := true

        ; Click fixed position 72, 186 (window relative) without clicking found image
        MouseMove(WinX + 72, WinY + 186, 5)
        Sleep(300)
        Click(4)
        Sleep(500)
        MouseMove(WinX + 75, WinY + 189, 5)
        Sleep(300)
        Click()

        RunCount++
        RunCountText.Value := "Runs: " RunCount
        StatusText.Value := "Run #" RunCount " completed!"

        ; Swap equipped slots permanently after death/retry
        temp := GlobalSlotA
        GlobalSlotA := GlobalSlotB
        GlobalSlotB := temp

        return
    }

    ; Check for start button (meaning we died and respawned)
    ; => DISABLED: Methods repeat ONLY until Retry is found for all bosses now
    /*
    if (ImageSearch(&StartX, &StartY, WinX, WinY, WinX + WinW, WinY + WinH, "*50 " . A_ScriptDir . "\start.png")) {
        DeathFound := true
        ; Swap equipped slots permanently after death/retry
        temp := GlobalSlotA
        GlobalSlotA := GlobalSlotB
        GlobalSlotB := temp
        StatusText.Value := "☠️ Death detected! Resetting loop..."
        RunCount++
        RunCountText.Value := "Runs: " RunCount
    }
    */
}

;===========================================
; CUSTOM TOOLTIP WRAPPER
;===========================================
CustomToolTip(text := "") {
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
; AUDIO SLIDER CHANGE
;===========================================
AudioSliderChange(*) {
    global AudioThreshold
    AudioThreshold := AudioSlider.Value / 100
    AudioSliderText.Value := Format("{:.2f}", AudioThreshold)
}

;===========================================
; GET ROBLOX AUDIO PEAK LEVEL
; Uses Windows Core Audio COM API
;===========================================
GetRobloxAudioPeak() {
    try {
        ; Create IMMDeviceEnumerator
        deviceEnumerator := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}",
            "{A95664D2-9614-4F35-A746-DE8DB63617E6}")

        ; GetDefaultAudioEndpoint(eRender=0, eConsole=0)
        ComCall(4, deviceEnumerator, "UInt", 0, "UInt", 0, "Ptr*", &device := 0)

        ; Activate IAudioSessionManager2 {77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}
        iidBuf := Buffer(16)
        DllCall("ole32\CLSIDFromString", "Str", "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}", "Ptr", iidBuf)
        ComCall(3, device, "Ptr", iidBuf, "UInt", 23, "Ptr", 0, "Ptr*", &sessionMgr := 0)

        ; GetSessionEnumerator
        ComCall(5, sessionMgr, "Ptr*", &sessionEnum := 0)

        ; GetCount
        ComCall(3, sessionEnum, "Int*", &count := 0)

        peakVal := 0.0

        loop count {
            ; GetSession
            ComCall(4, sessionEnum, "Int", A_Index - 1, "Ptr*", &sessionCtrl := 0)

            ; QueryInterface for IAudioSessionControl2 {bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}
            iid2Buf := Buffer(16)
            DllCall("ole32\CLSIDFromString", "Str", "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}", "Ptr", iid2Buf)
            hr := DllCall(NumGet(NumGet(sessionCtrl, "Ptr"), 0, "Ptr"), "Ptr", sessionCtrl, "Ptr", iid2Buf, "Ptr*", &
            sessionCtrl2 := 0, "Int")

            if (hr = 0) {
                ; GetProcessId (method index 14)
                ComCall(14, sessionCtrl2, "UInt*", &pid := 0)

                ; Check if this PID belongs to Roblox
                procName := ""
                try procName := ProcessGetName(pid)

                if (InStr(procName, "Roblox")) {
                    ; QueryInterface for IAudioMeterInformation {C02216F6-8C67-4B5B-9D00-D008E73E0064}
                    iidMeter := Buffer(16)
                    DllCall("ole32\CLSIDFromString", "Str", "{C02216F6-8C67-4B5B-9D00-D008E73E0064}", "Ptr", iidMeter)
                    hrMeter := DllCall(NumGet(NumGet(sessionCtrl, "Ptr"), 0, "Ptr"), "Ptr", sessionCtrl, "Ptr",
                    iidMeter, "Ptr*", &meterInfo := 0, "Int")

                    if (hrMeter = 0) {
                        ; GetPeakValue (method index 3)
                        ComCall(3, meterInfo, "Float*", &peak := 0.0)
                        peakVal := peak
                        ObjRelease(meterInfo)
                    }
                }
                ObjRelease(sessionCtrl2)
            }
            ObjRelease(sessionCtrl)
        }

        ObjRelease(sessionEnum)
        ObjRelease(sessionMgr)
        ObjRelease(device)

        return peakVal
    } catch {
        return 0.0
    }
}

;===========================================
; GET ROBLOX CENTER
;===========================================
GetRobloxCenter(&CenterX, &CenterY) {
    if WinExist("Roblox") {
        WinGetPos(&RobloxX, &RobloxY, &RobloxW, &RobloxH, "Roblox")
        CenterX := RobloxX + (RobloxW / 2)
        CenterY := RobloxY + (RobloxH / 2)
    } else {
        CenterX := A_ScreenWidth / 2
        CenterY := A_ScreenHeight / 2
    }
}

;===========================================
; ROTATE CAMERA & TARGET (SLOW)
;===========================================
RotateCameraAndTarget() {
    Click("Right Down")
    Sleep(50)
    ; Slow rotation - smaller mouse delta, spread over multiple steps
    loop 5 {
        DllCall("mouse_event", "UInt", 0x0001, "Int", 90, "Int", 0, "UInt", 0, "UPtr", 0)
        Sleep(30)
    }
    Sleep(50)

    Click("Right Up")
    Sleep(50)
    GetRobloxCenter(&CenterX, &CenterY)
    MouseMove(CenterX, CenterY, 0)
    Sleep(50)

    Send("{z Down}")
    Sleep(50)
    Send("{z Up}")
    Sleep(50)

    Send("{y Down}")
    Sleep(50)
    Send("{y Up}")
    Sleep(50)

    Send("{z Down}")
    Sleep(50)
    Send("{z Up}")
    Sleep(50)
}

;===========================================
; FULL CAMERA SCAN (4 rotations + air jumps)
;===========================================
FullCameraScan() {
    global EnemyDetected, AudioThreshold, GlobalSlotA, GlobalSlotB
    EnemyDetected := false
    CustomToolTip("Scanning...")
    StatusText.Value := "◎ Scanning..."

    loop 4 {
        ; Check audio before rotation
        peak := GetRobloxAudioPeak()
        if (peak > AudioThreshold) {
            EnemyDetected := true
            GetRobloxCenter(&CenterX, &CenterY)
            MouseClick("Middle", CenterX, CenterY)
            CustomToolTip("🔊 Enemy detected! Audio: " Format("{:.3f}", peak))
            StatusText.Value := "🔊 Enemy found! Attacking..."
            Sleep(500)
            return
        }

        ; Rotate camera
        RotateCameraAndTarget()

        ; 6 Air Jumps (Space)
        loop 6 {
            Send("{Space}")
            Sleep(200)

            ; Check audio during air jumps
            peak := GetRobloxAudioPeak()
            if (peak > AudioThreshold) {
                EnemyDetected := true
                GetRobloxCenter(&CenterX, &CenterY)
                MouseClick("Middle", CenterX, CenterY)
                CustomToolTip("🔊 Enemy detected! Audio: " Format("{:.3f}", peak))
                StatusText.Value := "🔊 Enemy found! Attacking..."
                Sleep(500)
                return
            }
        }

        ; Wait 5 seconds between rotations (skip wait after last rotation)
        if (A_Index < 4) {
            ; Check audio periodically during the 5s wait
            loop 10 {
                Sleep(500)
                peak := GetRobloxAudioPeak()
                if (peak > AudioThreshold) {
                    EnemyDetected := true
                    GetRobloxCenter(&CenterX, &CenterY)
                    MouseClick("Middle", CenterX, CenterY)
                    CustomToolTip("🔊 Enemy detected! Audio: " Format("{:.3f}", peak))
                    StatusText.Value := "🔊 Enemy found! Attacking..."
                    return
                }
            }
        }
    }

    ; No enemy detected after full scan - Reset character (Esc, R, Enter)
    if (!EnemyDetected) {
        CustomToolTip("No enemy found - Resetting...")
        StatusText.Value := "⚠️ No enemy - Resetting character..."
        Sleep(300)
        Send("{Escape}")
        Sleep(300)
        Send("r")
        Sleep(300)
        Send("{Enter}")
        Sleep(500)
        Sleep(1000)

        ; Swap equipped slots permanently after manual game reset
        temp := GlobalSlotA
        GlobalSlotA := GlobalSlotB
        GlobalSlotB := temp
    }

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
    global ActiveMethod, StartTime, IsRunning, RetryFound, DeathFound, DomainUsed, GlobalSlotA, GlobalSlotB, RunCount,
        RunCountText

    if (!IsRunning) {
        StartTime := A_TickCount
        IsRunning := true
    }

    ; Auto-resize Roblox window to top-left 800x600 and snap GUI next to it
    if WinExist("Roblox") {
        WinMove(0, 0, 800, 600, "Roblox")
        MainGui.Show("x800 y0")  ; Snap GUI to right edge of Roblox
        StatusText.Value := "Roblox window → 800x600"
        Sleep(500)
    } else {
        StatusText.Value := "⚠️ Roblox window not found!"
        Sleep(1000)
    }

    StatusText.Value := "Macro running... (Method " ActiveMethod ")"

    loop {
        CustomToolTip("Waiting for 'start.png'...")
        StatusText.Value := "Waiting for 'start.png'..."

        ; Wait for start image (also check audio & retry)
        loop {
            if WinExist("Roblox")
                WinGetPos(&WinX, &WinY, &WinW, &WinH, "Roblox")
            else {
                WinX := 0, WinY := 0, WinW := A_ScreenWidth, WinH := A_ScreenHeight
            }

            if ImageSearch(&StartX, &StartY, WinX, WinY, WinX + WinW, WinY + WinH, "*50 " . A_ScriptDir . "\start.png")
                break

            ; Check for Retry Button while waiting
            if ImageSearch(&FoundX, &FoundY, WinX, WinY, WinX + WinW, WinY + WinH, "*60 retry.png") {
                RetryFound := true

                ; Click fixed position 72, 186 (window relative) without clicking found image
                MouseMove(WinX + 72, WinY + 186, 5)
                Sleep(300)
                Click(4)
                Sleep(500)
                MouseMove(WinX + 75, WinY + 189, 5)
                Sleep(300)
                Click()

                RunCount++
                RunCountText.Value := "Runs: " RunCount
                StatusText.Value := "Run #" RunCount " completed!"

                ; Permanently swap abilities after retry
                temp := GlobalSlotA
                GlobalSlotA := GlobalSlotB
                GlobalSlotB := temp

                ; To avoid running the execution right after this, we continue the outer loop.
                ; But since we are inside an inner loop, we can just break, and handle it below.
                break
            }

            ; Also check if Roblox audio spikes (enemy nearby)
            peak := GetRobloxAudioPeak()
            if (peak > AudioThreshold) {
                CustomToolTip("🔊 Audio detected: " Format("{:.3f}", peak) " - skipping search!")
                break
            }
            Sleep(2000)
        }

        CustomToolTip("Executing Method " ActiveMethod)
        StatusText.Value := "Start found - Running..."

        ; Use the permanently tracked slots
        SlotA := GlobalSlotA
        SlotB := GlobalSlotB

        ; Reset flags
        RetryFound := false
        DeathFound := false
        DomainUsed := false

        ; Special setup for all bosses (Awakened Lightning uses basic dashed setup without Onetap)
        if (GlobalSelectedBoss != "") {
            CustomToolTip(GlobalSelectedBoss ": Setup...")
            StatusText.Value := GlobalSelectedBoss " Setup..."

            GetRobloxCenter(&CenterX, &CenterY)

            MouseMove(CenterX, CenterY, 0)

            Click "right"

            Sleep(500)

            if (OnetapCheck.Value == 1) {
                StatusText.Value := "Onetap Mode Running..."
                CustomToolTip("Onetap Enabled!")

                if (GlobalSelectedBoss = "King of Curses" || GlobalSelectedBoss = "Awakened Zen'in" ||
                    GlobalSelectedBoss = "God of Lightning") {
                    StatusText.Value := "Dashing forward for " GlobalSelectedBoss "..."
                    Send("{e down}")
                    Sleep(100)
                    Send("{e up}")
                    Sleep(300)
                }

                ; START background retry checker early so we can break the loop
                SetTimer(BackgroundRetryCheck, 2000)

                loop {
                    CustomToolTip("Onetap Cycle " A_Index)

                    if WinExist("Roblox")
                        WinGetPos(&WinX, &WinY, &WinW, &WinH, "Roblox")
                    else
                        WinX := 0, WinY := 0, WinW := A_ScreenWidth, WinH := A_ScreenHeight

                    if ImageSearch(&FoundX, &FoundY, WinX, WinY, WinX + WinW, WinY + WinH, "*60 retry.png") {
                        RetryFound := true
                        break
                    }

                    Send(SlotA)
                    Sleep(300)
                    Send("{c down}")
                    Sleep(500)
                    Send("{c up}")
                    Sleep(300)

                    MouseMove(WinX + 72, WinY + 186, 5)
                    Sleep(300)
                    Click(4)
                    Sleep(500)
                    MouseMove(WinX + 75, WinY + 189, 5)
                    Sleep(300)
                    Click()

                    Send("x down")
                    Sleep(500)
                    Send("x up")
                    Sleep(300)

                    if ImageSearch(&FoundX, &FoundY, WinX, WinY, WinX + WinW, WinY + WinH, "*60 retry.png") {
                        RetryFound := true
                        break
                    }

                    Send(SlotB)
                    Sleep(300)

                    MouseMove(WinX + 72, WinY + 186, 5)
                    Sleep(300)
                    Click(4)
                    Sleep(500)
                    MouseMove(WinX + 75, WinY + 189, 5)
                    Sleep(300)
                    Click()

                }
            } else {
                ; 4 small rotations for a complete rotation
                loop 4 {
                    Click("Right Down")
                    Sleep(50)
                    loop 5 {
                        DllCall("mouse_event", "UInt", 0x0001, "Int", 90, "Int", 0, "UInt", 0, "UPtr", 0)
                        Sleep(30)
                    }
                    Sleep(50)
                    Click("Right Up")
                    Sleep(300)
                    MouseMove(CenterX, CenterY, 0)
                    Sleep(100)

                    ; Dash forward in each direction once (skipped for Sorcerer Killer)
                    if (GlobalSelectedBoss != "Sorcerer Killer") {
                        if (GlobalSelectedBoss != "Disaster Flame Curse") {
                            Send "{Space down}"
                            Sleep 50
                            Send "{Space up}"
                            Sleep 100
                        }
                        Send "{e down}"
                        Sleep 100
                        Send "{e up}"
                        Sleep 300
                    }
                }
                Sleep(500)

                ; Single dash forward at the very end purely for Sorcerer Killer
                if (GlobalSelectedBoss = "Sorcerer Killer") {
                    Send "{e down}"
                    Sleep 100
                    Send "{e up}"
                    Sleep 300
                }
            }
        }

        ; START background retry checker (every 2 seconds)
        SetTimer(BackgroundRetryCheck, 2000)

        ; === ATTACK SEQUENCE ===
        if (ActiveMethod = 1) {
            ; METHOD 1: Fast - Slot 1 only
            StatusText.Value := "Method 1 running..."
            loop {
                if (RetryFound || DeathFound)
                    break
                CustomToolTip("M1 - Cycle " A_Index)
                RotateCameraAndTarget()

                Send(SlotA)
                Sleep(400)
                Send("{x Down}")
                Sleep(500)
                Send("{x Up}")
                Sleep(300)

                if (RetryFound || DeathFound)
                    break

                Send("{r Down}")
                Sleep(500)
                Send("{r Up}")
                Sleep(300)

                if (RetryFound || DeathFound)
                    break

                Send("{f Down}")
                Sleep(500)
                Send("{f Up}")
                Sleep(300)
                Send(SlotA)

                ; Domain check
                PerformDomain()

                if (RetryFound || DeathFound)
                    break
                Sleep(500)
            }

        } else if (ActiveMethod = 2) {
            ; METHOD 2: Slot 1 + Slot 2 (No Ult)
            StatusText.Value := "Method 2 running..."
            loop {
                if (RetryFound || DeathFound)
                    break
                CustomToolTip("M2 - Cycle " A_Index)
                RotateCameraAndTarget()

                ; Slot 1
                Send(SlotA)
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

                if (RetryFound || DeathFound)
                    break

                ; Rotate between slots
                RotateCameraAndTarget()

                ; Slot 2
                Send(SlotB)
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

                if (RetryFound || DeathFound)
                    break
                Sleep(500)
            }

        } else if (ActiveMethod = 3) {
            ; METHOD 3: Slot 1 + Slot 2 + Ult (C)
            StatusText.Value := "Method 3 running..."
            loop {
                if (RetryFound || DeathFound)
                    break
                CustomToolTip("M3 - Cycle " A_Index)
                RotateCameraAndTarget()

                ; Slot 1
                Send(SlotA)
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

                if (RetryFound || DeathFound)
                    break

                ; Rotate between slots
                RotateCameraAndTarget()

                ; Slot 2
                Send(SlotB)
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

                if (RetryFound || DeathFound)
                    break
                Sleep(500)
            }
        }

        ; STOP background retry checker
        SetTimer(BackgroundRetryCheck, 0)
        CustomToolTip()

        if (DeathFound || (!EnemyDetected && !RetryFound)) {
            StatusText.Value := "Cycle aborted - Skipping wait..."
            Sleep(1000)
        } else if (RetryFound) {
            StatusText.Value := "Retry - Resetting cycle..."
            Sleep(1000)
        } else {
            StatusText.Value := "Cycle done - Waiting 10s..."
            Sleep(10000)
        }
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

$ESC:: ExitApp()