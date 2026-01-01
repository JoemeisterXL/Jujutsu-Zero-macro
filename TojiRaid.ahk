;===========================================
; CONFIG & AUTO-LOGIN
;===========================================
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SendMode Event
SetDefaultMouseSpeed, 0

; --- DISCORD WEBHOOK URL - INSERT YOUR URL HERE ---
global DiscordURL := "https://discord.com/api/webhooks/1456294811874361396/HGKycgLuSP04RGjp30liM4zvjsNHjB5ogUIUBPs6Y5TIGD_pwNWRzA6bOnk8_tu7G6pf"

; Load saved data
IniRead, SavedID, config.ini, Discord, ID, % ""
IniRead, SavedUsername, config.ini, Discord, Username, % ""
IniRead, SavedWebhookEnabled, config.ini, Discord, WebhookEnabled, 1
IniRead, SavedThreadID, config.ini, Discord, ThreadID, % ""

; Statistics Variables
global RunCount := 0
global TotalTime := 0
global SessionStart := 0
global CurrentRunStart := 0
global WebhookEnabled := SavedWebhookEnabled
global ThreadID := SavedThreadID

; Scaling Logic
RefWidth := 1920
RefHeight := 1080
ScaleX := A_ScreenWidth / RefWidth
ScaleY := A_ScreenHeight / RefHeight
Target1_X := 747 * ScaleX
Target1_Y := 413 * ScaleY
Target2_X := 10 * ScaleX
Target2_Y := 240 * ScaleY

global ActiveMethod := 1

;===========================================
; CREATE GUI
;===========================================
Gui, +AlwaysOnTop
Gui, Color, 0x1a1a1a
Gui, Font, s10 cWhite Bold, Segoe UI

Gui, Add, Text, x20 y15 w300 Center, === RAID MACRO v4.0 ===

Gui, Font, s10 cWhite norm

; 1. Method Selection (JETZT AN ERSTER STELLE)
Gui, Add, GroupBox, x20 y50 w300 h150 cSilver, Method Selection
Gui, Add, Radio, x40 y75 w260 vMethodRadio1 gMethodSwitch Checked cWhite, Method 1: Slot 1 move
Gui, Add, Radio, x40 y100 w260 vMethodRadio2 gMethodSwitch cWhite, Method 2: Both Slots
Gui, Add, Radio, x40 y125 w260 vMethodRadio3 gMethodSwitch cWhite, Method 3: Festering/Spear
Gui, Font, s9 Bold cYellow
Gui, Add, Text, x40 y160 w260 vMethodText, Active Method: 1
Gui, Font, s10 norm cWhite

; 2. Live Statistics (JETZT AN ZWEITER STELLE)
Gui, Add, GroupBox, x20 y210 w300 h100 cSilver, Live Statistics
Gui, Add, Text, x30 y235 w270 vRunCountText cWhite, Runs: 0
Gui, Add, Text, x30 y260 w270 vCurrentRunText cWhite, Current Run: --:--
Gui, Add, Text, x30 y285 w270 vSessionTimeText cWhite, Session Time: 00:00:00

; 3. Controls (JETZT AN DRITTER STELLE)
Gui, Add, GroupBox, x20 y320 w300 h80 cSilver, Controls
Gui, Add, Text, x40 y345 cWhite, F1: Start | F2: Stop | F3/F4/F5: Quick Switch
Gui, Add, Text, x40 y365 cWhite, F6: Test Webhook | ESC: Exit

; 4. Discord Synchronization (JETZT AN VIERTER STELLE)
Gui, Add, GroupBox, x20 y410 w300 h200 cSilver, Discord Synchronization
Gui, Add, Text, x30 y435 cWhite, Discord User ID:
Gui, Add, Edit, x30 y455 w240 vDiscordID, %SavedID%
Gui, Add, Text, x30 y485 cWhite, Username (optional):
Gui, Add, Edit, x30 y505 w240 vDiscordUsername, %SavedUsername%

; Thread ID Field
Gui, Font, s9 cRed Bold
Gui, Add, Text, x30 y532, 🔒 Thread ID (REQUIRED):
Gui, Font, s10 cWhite norm
Gui, Add, Edit, x30 y550 w240 vThreadIDInput, %SavedThreadID%

; Webhook Toggle
Gui, Font, s9 Bold cWhite
if (WebhookEnabled = 1)
    Gui, Add, Checkbox, x30 y578 w240 vWebhookToggle gToggleWebhook Checked cWhite, 📡 Webhook Notifications
else
    Gui, Add, Checkbox, x30 y578 w240 vWebhookToggle gToggleWebhook cWhite, 📡 Webhook Notifications
Gui, Font, s10 norm

; 5. Connection Status (Ganz unten)
Gui, Add, GroupBox, x20 y620 w300 h100 cSilver, Connection Status
Gui, Font, s9 Bold
Gui, Add, Text, x30 y645 w270 vLoginStatus cRed, ⚠ Not connected
Gui, Add, Text, x30 y670 w270 vThreadStatus cRed, 🔒 Thread NOT configured
Gui, Font, s10 norm cWhite

Gui, Add, Button, x100 y690 w140 h30 gLoginDiscord, Login & Save
Gui, Add, Button, x20 y725 w300 h25 gShowThreadInfo, ℹ️ How to create a Thread?

Gui, Show, w340 h770, Toji Raid Macro v4.0

; Timer for Live Updates
SetTimer, UpdateTimer, 1000
return

;===========================================
; SHOW THREAD INFO
;===========================================
ShowThreadInfo:
    MsgBox, 64, Thread Setup Guide, 
    (
📌 HOW TO CREATE YOUR PRIVATE THREAD:

    1️⃣ Go to your Discord Server
    2️⃣ Create a new Thread in a channel
3️⃣ Enable Developer Mode:
    Discord Settings → Advanced → Developer Mode
    4️⃣ Right-click on the Thread → "Copy ID"
    5️⃣ Paste the Thread ID in this macro

🔒 SECURITY:
    • Thread ID is REQUIRED!
    • Prevents spam in public channels
    • Each user needs their own thread
    • Perfect for multi-user setup!

⚠️ IMPORTANT:
    Without Thread ID, no messages can be sent!
    )
return

;===========================================
; WEBHOOK TOGGLE
;===========================================
ToggleWebhook:
    Gui, Submit, NoHide
    WebhookEnabled := WebhookToggle
    IniWrite, %WebhookEnabled%, config.ini, Discord, WebhookEnabled

    if (WebhookEnabled)
        ToolTip, Webhook notifications enabled ✓
    else
        ToolTip, Webhook notifications disabled ✗

    SetTimer, RemoveToolTip, 2000
return

RemoveToolTip:
    ToolTip
    SetTimer, RemoveToolTip, Off
return

;===========================================
; DISCORD LOGIN
;===========================================
LoginDiscord:
    Gui, Submit, NoHide
    if (DiscordID == "")
    {
        MsgBox, 16, Error, Please enter Discord User ID!
        return
    }

    ; Thread ID Check - REQUIRED!
    if (ThreadIDInput == "")
    {
        MsgBox, 48, Thread ID missing!, 
        (
        ⚠️ Thread ID is REQUIRED!

        Without Thread ID, no messages can be sent.
        This prevents spam in public channels.

        Click "ℹ️ How to create a Thread?" for help.
            )
        return
    }

    ; Save
    IniWrite, %DiscordID%, config.ini, Discord, ID
    IniWrite, %DiscordUsername%, config.ini, Discord, Username
    IniWrite, %ThreadIDInput%, config.ini, Discord, ThreadID

    ; Set Thread ID globally
    ThreadID := ThreadIDInput

    ; Status Update
    GuiControl,, LoginStatus, ✓ Connected as: %DiscordUsername%
    GuiControl, +cLime, LoginStatus

    GuiControl,, ThreadStatus, 🔒 Thread: Configured ✓
    GuiControl, +cLime, ThreadStatus

    ; Send test message (only if webhook active)
    if (WebhookEnabled)
    {
        userName := (DiscordUsername != "") ? DiscordUsername : "User"
            DiscordEmbed("🟢 Connection established", "User " . userName . " successfully connected with private thread!", "3066993")
        }

        MsgBox, 64, Success, Discord connection with private thread established!
        return

        ;===========================================
        ; DISCORD FUNCTIONS - ONLY WITH THREAD
        ;===========================================
        DiscordEmbed(Title, Description, Color)
        {
            global DiscordURL, DiscordID, WebhookEnabled, ThreadID

            ; Checks
            if (DiscordID == "" || !WebhookEnabled || ThreadID == "")
                return

            ; Escape Quotes AND Line breaks in Description
            StringReplace, Description, Description, ", \", All
            StringReplace, Description, Description, `n, \n, All

            ; Create JSON Embed
            JsonPayload := "{"
            JsonPayload .= """content"": ""<@" . DiscordID . ">"""
            JsonPayload .= ",""embeds"": [{"
            JsonPayload .= """title"": """ . Title . """"
            JsonPayload .= ",""description"": """ . Description . """"
            JsonPayload .= ",""color"": " . Color
            JsonPayload .= "}]}"

            ; URL with Thread ID (ALWAYS required)
            finalURL := DiscordURL . "?thread_id=" . ThreadID

            try
            {
                WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
                WebRequest.Open("POST", finalURL, false)
                WebRequest.SetRequestHeader("Content-Type", "application/json")
                WebRequest.Send(JsonPayload)
            }
        }

        DiscordScreenshot(RunNum, RunTime, Method)
        {
            global DiscordURL, DiscordID, DiscordUsername, TotalTime, WebhookEnabled, ThreadID

            ; Checks
            if (DiscordID == "" || !WebhookEnabled || ThreadID == "")
                return

            ; Create Screenshot
            SnapFile := A_ScriptDir . "\run_" . RunNum . ".png"
            if FileExist(SnapFile)
                FileDelete, %SnapFile%

            psCommand := "powershell -NoProfile -Command ""[Reflection.Assembly]::LoadWithPartialName('System.Drawing'); [Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $bmp = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height); $graphics = [System.Drawing.Graphics]::FromImage($bmp); $graphics.CopyFromScreen(0,0,0,0, $bmp.Size); $bmp.Save('" . SnapFile . "', [System.Drawing.Imaging.ImageFormat]::Png); $graphics.Dispose(); $bmp.Dispose();"""
            RunWait, %psCommand%, , Hide

            ; Calculate average time
            avgTime := RunNum > 0 ? Round(TotalTime / RunNum, 1) : 0

            ; Username
        userName := (DiscordUsername != "") ? DiscordUsername : "User"

            ; URL with Thread ID (ALWAYS required)
            finalURL := DiscordURL . "?thread_id=" . ThreadID

            ; Write JSON Payload to separate file
            jsonFile := A_ScriptDir . "\payload.json"
            FileDelete, %jsonFile%

            jsonContent := "{"
            jsonContent .= """embeds"": [{"
            jsonContent .= """title"": "" Run #" . RunNum . " completed"""
            jsonContent .= ",""color"": 5814783"
            jsonContent .= ",""fields"": ["
            jsonContent .= "{""name"": "" User"", ""value"": """ . userName . """, ""inline"": true},"
            jsonContent .= "{""name"": "" Method"", ""value"": ""Method " . Method . """, ""inline"": true},"
            jsonContent .= "{""name"": "" Run Time"", ""value"": """ . RunTime . """, ""inline"": true},"
            jsonContent .= "{""name"": "" Average"", ""value"": """ . avgTime . "s"", ""inline"": true},"
            jsonContent .= "{""name"": "" Total Runs"", ""value"": """ . RunNum . """, ""inline"": true},"
            jsonContent .= "{""name"": "" Session Time"", ""value"": """ . FormatSeconds(TotalTime) . """, ""inline"": true}"
            jsonContent .= "]}]}"

            FileAppend, %jsonContent%, %jsonFile%, UTF-8

            ; Simple Curl command with JSON from file
            curlCmd := "curl -X POST """ . finalURL . """ -F ""payload_json=<" . jsonFile . """ -F ""file=@" . SnapFile . """"
            RunWait, %curlCmd%, , Hide

            ; Cleanup
            Sleep, 500
            FileDelete, %jsonFile%
            FileDelete, %SnapFile%
        }

        FormatSeconds(seconds)
        {
            hours := Floor(seconds / 3600)
            minutes := Floor(Mod(seconds, 3600) / 60)
            secs := Floor(Mod(seconds, 60))

            if (hours > 0)
                return hours . "h " . minutes . "m " . secs . "s"
            else if (minutes > 0)
                return minutes . "m " . secs . "s"
            else
                return secs . "s"
        }

        ;===========================================
        ; TIMER UPDATE
        ;===========================================
        UpdateTimer:
            if (SessionStart > 0)
            {
                elapsed := (A_TickCount - SessionStart) / 1000
                sessionTime := FormatSeconds(elapsed)
                GuiControl,, SessionTimeText, Session Time: %sessionTime%

                if (CurrentRunStart > 0)
                {
                    runElapsed := (A_TickCount - CurrentRunStart) / 1000
                    mins := Floor(runElapsed / 60)
                    secs := Floor(Mod(runElapsed, 60))

                    ; Add leading zero if needed
                    if (secs < 10)
                        secsStr := "0" . secs
                    else
                        secsStr := secs

                    timeStr := mins . ":" . secsStr
                    GuiControl,, CurrentRunText, Current Run: %timeStr%
                }
            }
        return

        ;===========================================
        ; METHOD SWITCH
        ;===========================================
        MethodSwitch:
            Gui, Submit, NoHide
            if (MethodRadio1)
                ActiveMethod := 1
            else if (MethodRadio2)
                ActiveMethod := 2
            else if (MethodRadio3)
                ActiveMethod := 3

            GuiControl,, MethodText, Active Method: %ActiveMethod%
        return

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
        ; TEST WEBHOOK
        ;===========================================
        F6::
            Gui, Submit, NoHide
            if (DiscordID == "")
            {
                MsgBox, 16, Error, Please login first!
                return
            }
            if (ThreadID == "")
            {
                MsgBox, 48, Thread ID missing!, Thread ID is required!`nPlease enter and save Thread ID.
                return
            }
            if (!WebhookEnabled)
            {
                MsgBox, 48, Info, Webhook notifications are disabled!`nPlease enable the checkbox in the GUI.
                return
            }

            DiscordEmbed("🔔 Test Message", "Webhook is working perfectly in private thread!", "3447003")
            MsgBox, 64, Test, Test message sent to your private thread!
        return

        ;===========================================
        ; MAIN MACRO - F1
        ;===========================================
        F1::

            if (ThreadID == "" && WebhookEnabled)
            {
                MsgBox, 48, Thread ID missing!, Thread ID is required for webhook messages!`n`nMacro starts WITHOUT Discord notifications.
                }

            ; Session Start
            SessionStart := A_TickCount
            RunCount := 0
            TotalTime := 0

            if (WebhookEnabled && ThreadID != "")
            {
                userName := (DiscordUsername != "") ? DiscordUsername : "User"
                    DiscordEmbed("🚀 Macro started", "User " . userName . " started the macro - Method: " . ActiveMethod, "5763719")
                }

                Loop
                {
                    CurrentRunStart := A_TickCount
                    AlertSent := false
                    GuiControl,, CurrentRunText, Current Run: 00:00

                    ; Start Image Search
                    Loop
                    {
                        ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png
                        if (ErrorLevel = 0)
                            break

                        ; Alert after 60s (only if webhook active AND thread configured)
                        if (!AlertSent && (A_TickCount - CurrentRunStart > 60000) && WebhookEnabled && ThreadID != "")
                        {
                            DiscordEmbed("⚠️ WARNING", "No start button found for 60 seconds!", "16776960")
                            AlertSent := true
                        }
                        Sleep, 2000
                    }

                    RunCount++
                    GuiControl,, RunCountText, Runs: %RunCount%

                    ; === MACRO SEQUENCE ===
                    MouseMove, A_ScreenWidth/2, A_ScreenHeight/2, 3
                    Sleep, 200
                    Send, {WheelDown 5}
                    Sleep, 400
                    Send, 1
                    Sleep, 400
                    MouseMove, %Target1_X%, %Target1_Y%, 5
                    Click
                    Sleep, 500

                    ; === ATTACK SEQUENCES ===
                    if (ActiveMethod = 1)
                    {
                        Sleep, 800
                        Send, {c Down}
                        Sleep, 800
                        Send, {c Up}
                        Sleep, 7000
                    }
                    else if (ActiveMethod = 2)
                    {
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
                    else if (ActiveMethod = 3)
                    {
                        Send, {MButton}
                        Sleep, 500
                        Loop, 2
                        {
                            Send, {e Down}
                            Sleep, 200
                            Send, {e Up}
                            Sleep, 400
                        }
                        Send, 2
                        Sleep, 100
                        Send, 1
                        Loop, 2
                        {
                            Sleep, 700
                            Send, {r Down}
                            Sleep, 200
                            Send, {r Up}
                            Sleep, 400
                            Send, 2
                        }
                    }

                    ; === REWARD SKIP & SCREENSHOT ===
                    Sleep, 4000
                    MouseMove, %Target2_X%, %Target2_Y%, 2
                    Click

                    ; Calculate run time
                    runTime := Round((A_TickCount - CurrentRunStart) / 1000, 1)
                    TotalTime += runTime
                    runTimeFormatted := runTime . "s"

                    ; Send screenshot with stats (only if webhook active AND thread configured)
                    if (WebhookEnabled && ThreadID != "")
                        DiscordScreenshot(RunCount, runTimeFormatted, ActiveMethod)

                    Loop, 3
                    {
                        Sleep, 400
                        Click
                    }

                    ; === RETRY SEARCH ===
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

                    Sleep, 15000
                    CurrentRunStart := 0
                    GuiControl,, CurrentRunText, Current Run: --:--
                }
                return

                ;===========================================
                ; STOP MACRO - F2
                ;===========================================
                F2::
                    Gui, Submit, NoHide
                    if (SessionStart > 0 && WebhookEnabled && ThreadID != "")
                    {
                        totalSessionTime := FormatSeconds((A_TickCount - SessionStart) / 1000)
                        avgTime := RunCount > 0 ? Round(TotalTime / RunCount, 1) : 0

                        DiscordEmbed("🛑 Macro stopped", "Session ended - Runs: " . RunCount . " - Total Time: " . totalSessionTime . " - Average: " . avgTime . "s", "15158332")
                    }
                    Reload
                return

                ;===========================================
                ; EXIT
                ;===========================================
                GuiClose:
                ESC::
                    Gui, Submit, NoHide
                    if (SessionStart > 0 && WebhookEnabled && ThreadID != "")
                    {
                        totalSessionTime := FormatSeconds((A_TickCount - SessionStart) / 1000)
                        DiscordEmbed("👋 Macro ended", "Runs: " . RunCount . " | Time: " . totalSessionTime, "10070709")
                    }
                ExitApp
                return