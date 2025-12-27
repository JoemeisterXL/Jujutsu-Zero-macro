;Settings

#NoEnv

SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Screen

CoordMode, Pixel, Screen

;Event - Counter the mouse movement better

SendMode Event

SetDefaultMouseSpeed, 5

F1::

    Loop ; runs until user stops with F2

    {
        ToolTip, Run started
        ; search raid start screen to start the programm

        Loop

        {

            ImageSearch, StartX, StartY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 start.png

            if (ErrorLevel = 0)

            break ; Search is finished

            Sleep, 2000

        }
        ToolTip, Found first image
        ; Zoomes out

        Send, {WheelDown 5}

        Sleep, 400

        Send, 1

        Sleep, 400

        ; Move the mouse to the right position and klick one time

        MouseMove, 12, 237

        Sleep, 200

        Click, Down

        Sleep, 50

        Click, Up

        Sleep, 500

        ; Click the button to use the attack in raid

        Sleep, 500

        Send, {c Down}

        Sleep, 50

        Send, {c Up}

        Sleep, 9000

        ; Click to skip rewards fast

        Sleep, 500

        Click

        Sleep, 500

        Click

        Sleep, 2000

        ; search the image.png (Retry button)
        ToolTip, searching for retry button
            ; Definition der Bilder am Anfang des Skripts oder hier
        bilderListe := ["image1920x1080.png", "image1366x768.png", "image1760x990.png", "image2560x1440.png"] 
        ImageGefunden := false

        ; Versuche es insgesamt 4 Mal
        Loop, 4 
        {
            ToolTip, Search round %A_Index% of 4

            ; Gehe jedes Bild in der Liste durch
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
                    break 2 ; Bricht SOWOHL die 'for'-Schleife ALS AUCH die 'Loop 4' ab
                }
            }

            if (ImageGefunden)
                break

            Sleep, 1000 ; Warten bis zum nächsten Versuch, falls kein Bild gefunden wurde
        }
        ToolTip, Run finished (Failed if its not on retry)

        Sleep, 9000

        ToolTip

    }

return

F2::ExitApp

