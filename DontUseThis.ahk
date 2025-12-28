;Settings
#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SendMode Event
SetDefaultMouseSpeed, 5

F1::
    Loop ; Hauptschleife (läuft bis F2 gedrückt wird)
    {
        ToolTip, Warte auf Raid-Start...
        ; Suche nach dem Start-Bild
        Loop
        {
            ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png
            if (ErrorLevel = 0)
                break 
            Sleep, 2000
        }

        ToolTip, Raid gestartet!
        Send, {WheelDown 5}
        Sleep, 400

        ; Erster Schuss auf Position 750, 414 mit Taste 'c'
        Send, 1
        MouseMove, 750, 414
        Sleep, 500
        Send, {c Down}
        Sleep, 50
        Send, {c Up}
        Sleep, 9000

        ; --- ANGREIF-SCHLEIFE START ---
        ; Diese Schleife läuft so lange, bis einer der Retry-Buttons gefunden wird
        ToolTip, Greife an und suche Retry-Button...

        RetryGefunden := false
        Loop
        {
            ; 1. Angriffs-Sequenz auf Position 960, 660
            MouseMove, 960, 660, 0
            Send, 1
            for each, key in ["c", "x", "r", "f"]
            {
                Send, %key%
                Sleep, 400
            }

            ; 2. Angriffs-Sequenz mit Taste '2' (und optional auch c,x,r,f)
            Send, 2
            Sleep, 50
            for each, key in ["c", "x", "r", "f"]
            {
                Send, %key%
                Sleep, 400
            }

            MouseMove, 10, A_ScreenHeight - 10, 5
            Sleep, 10
            Click
            Sleep, 10
            Click

            ; 3. PRÜFUNG: Ist der Kampf vorbei? (Retry Button Check)
            bilderListe := ["image1920x1080.png", "image1366x768.png", "image1760x990.png", "image2560x1440.png"]

            for index, dateiName in bilderListe 
            {
                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *60 %dateiName%
                if (ErrorLevel = 0)
                {
                    ToolTip, Retry gefunden! Beende Kampf.
                    MouseMove, %FoundX%, %FoundY%
                    Sleep, 200
                    Click, 2 ; Doppelklick auf Retry
                    RetryGefunden := true
                    break ; Bricht die Bilder-Suche ab
                }
            }

            if (RetryGefunden)
                break ; Bricht die Angriffs-Schleife ab und geht zum nächsten Raid-Durchlauf

            ; Kurze Pause, damit das System nicht überlastet
            Sleep, 500 
        }
        ; --- ANGREIF-SCHLEIFE ENDE ---

        ToolTip, Raid beendet. Warte auf Neustart...
        Sleep, 5000
    }
return

F2::ExitApp