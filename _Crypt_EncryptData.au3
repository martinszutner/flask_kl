#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

Global $g_hKey = -1, $g_idInputEdit = -1, $g_idOutputEdit = -1

Example()

Func Example()
	Local $hGUI = GUICreate("Realtime Encryption", 400, 320)
	$g_idInputEdit = GUICtrlCreateEdit("", 0, 0, 400, 150, $ES_WANTRETURN)
	$g_idOutputEdit = GUICtrlCreateEdit("", 0, 150, 400, 150, $ES_READONLY)
	Local $idCombo = GUICtrlCreateCombo("", 0, 300, 100, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData($idCombo, "1|2|3|4|5|6|7", "3")
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	GUISetState(@SW_SHOW, $hGUI)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit


				Local $sRead = GUICtrlRead($g_idInputEdit)
				If StringStripWS($sRead, $STR_STRIPALL) <> "" Then ; Check there is text available to encrypt.
					Local $bEncrypted = DescifrarDesplazamiento(GUICtrlRead($g_idInputEdit),3) ; Encrypt the text with the cryptographic key.
					GUICtrlSetData($g_idOutputEdit, $bEncrypted) ; Set the output box with the encrypted text.
				EndIf
		EndSwitch
	WEnd

	GUIDelete($hGUI) ; Delete the previous GUI and all controls.
	_Crypt_DestroyKey($g_hKey) ; Destroy the cryptographic key.
	_Crypt_Shutdown() ; Shutdown the crypt library.
EndFunc   ;==>Example

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $lParam

	Switch _WinAPI_LoWord($wParam)
		Case $g_idInputEdit
			Switch _WinAPI_HiWord($wParam)
				Case $EN_CHANGE
					Local $bEncrypted = DescifrarDesplazamiento(GUICtrlRead($g_idInputEdit),3) ; Encrypt the text with the cryptographic key.
					GUICtrlSetData($g_idOutputEdit, $bEncrypted) ; Set the output box with the encrypted text.
			EndSwitch
	EndSwitch
EndFunc   ;==>WM_COMMAND


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

