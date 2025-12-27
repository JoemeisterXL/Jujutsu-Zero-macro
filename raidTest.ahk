;Settings
#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

;Event - Wichtig für Spiele
SendMode Event
SetDefaultMouseSpeed, 0 ; Auf 0 setzen für sofortige Reaktion in der Schleife

F1::
    Loop ; Läuft bis F2 gedrückt wird
    {
        ToolTip, Run started
        Loop
        {
            ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png
            if (ErrorLevel = 0)
                break 
            Sleep, 2000
        }

        ToolTip, Found first image

        ; --- VERBESSERTE KAMERA-DREHUNG ---
        ; 1. Maus in die Bildschirmmitte bewegen (verhindert Hängenbleiben am Rand)
        MouseMove, A_ScreenWidth/2, A_ScreenHeight/2, 0
        Sleep, 100

        ; 2. Rechte Maustaste drücken
        Click, Right, Down
        Sleep, 100

        ; 3. In kleinen Schritten exakt nach links bewegen (Loop für Stabilität)
        ; Ändere "40" für die Weite der Drehung
        ; Ersetzt Loop 2 mit -2.9/3
        MouseMove, -5, 0, 0, R

        Sleep, 100
        Click, Right, Up ; Loslassen

        ; 4. Kurz Strg an und aus
        Send, {Control}
        Sleep, 100
        Send, {Control}
        ; --- DREHUNG ENDE ---

        Sleep, 400
        Send, {WheelDown 5}
        Sleep, 400
        Send, 1
        Sleep, 400

        ; Klick auf Position 12, 474
        MouseMove, 12, 474
        Sleep, 200
        Click, Down
        Sleep, 50
        Click, Up
        Sleep, 500

        ; Angriff (Taste C)
        Sleep, 500
        Send, {c Down}
        Sleep, 50
        Send, {c Up}
        Sleep, 9000

        ; Rewards überspringen
        Sleep, 500
        Click
        Sleep, 500
        Click
        Sleep, 2000

        ; Retry Button suchen
        ToolTip, searching for retry button
            bilderListe := ["image1920x1080.png", "image1366x768.png", "image1760x990.png", "image2560x1440.png"] 
        ImageGefunden := false

        Loop, 4 
        {
            ToolTip, Search round %A_Index% of 4
            for index, dateiName in bilderListe 
            {
                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *60 %dateiName%
                if (ErrorLevel = 0)
                {
                    MouseMove, %FoundX%, %FoundY%
                    Sleep, 100
                    Loop, 2 {
                        Click
                        Sleep, 100
                    }
                    ImageGefunden := true
                    break 2 
                }
            }
            if (ImageGefunden)
                break
            Sleep, 1000 
        }
        ToolTip, Run finished
        Sleep, 9000
        ToolTip
    }
return

F2::ExitApp