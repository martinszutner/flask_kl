#include <ComboConstants.au3>
#include <Crypt.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

Example()

Func Example()
	Local $iAlgorithm = $CALG_RC4

	Local $hGUI = GUICreate("File Decrypter", 425, 100)
	Local $idSourceInput = GUICtrlCreateInput("", 5, 5, 200, 20)
	Local $idSourceBrowse = GUICtrlCreateButton("...", 210, 5, 35, 20)

	Local $idDestinationInput = GUICtrlCreateInput("", 5, 30, 200, 20)
	Local $idDestinationBrowse = GUICtrlCreateButton("...", 210, 30, 35, 20)

	GUICtrlCreateLabel("Password:", 5, 60, 200, 20)
	Local $idPasswordInput = GUICtrlCreateInput("", 5, 75, 200, 20)

	Local $idDecrypt = GUICtrlCreateButton("Decrypt", 355, 70, 65, 25)
	GUISetState(@SW_SHOW, $hGUI)

	Local $sDestinationRead = "", $sFilePath = "", $sPasswordRead = "", $sSourceRead = ""
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idSourceBrowse
				$sFilePath = FileOpenDialog("Select a file to decrypt.", "", "All files (*.*)") ; Select a file to decrypt.
				If @error Then
					ContinueLoop
				EndIf
				GUICtrlSetData($idSourceInput, $sFilePath) ; Set the inputbox with the filepath.

			Case $idDestinationBrowse
				$sFilePath = FileSaveDialog("Save the file as ...", "", "All files (*.*)") ; Select a file to save the decrypted data to.
				If @error Then
					ContinueLoop
				EndIf
				GUICtrlSetData($idDestinationInput, $sFilePath) ; Set the inputbox with the filepath.

			Case $idDecrypt
				$iAlgorithm = $CALG_RC4
				$sSourceRead = GUICtrlRead($idSourceInput) ; Read the source filepath input.
				$sDestinationRead = GUICtrlRead($idDestinationInput) ; Read the destination filepath input.
				$sPasswordRead = GUICtrlRead($idPasswordInput) ; Read the password input.
				If StringStripWS($sSourceRead, $STR_STRIPALL) <> ""  And FileExists($sSourceRead) Then ; Check there is a file available to decrypt and a password has been set.

						; Read the current script file into an array using the filepath.
						Local $aArray = FileReadToArray($sSourceRead)
						If @error Then
							MsgBox($MB_SYSTEMMODAL, "", "There was an error reading the file. @error: " & @error) ; An error occurred reading the current script file.
						Else
							For $i = 0 To UBound($aArray) - 1 ; Loop through the array.
								MsgBox($MB_SYSTEMMODAL, "", DescifrarDesplazamiento($aArray[$i],3)) ; Display the contents of the array.
							Next
							Exit Func
						EndIf
				Else
					MsgBox($MB_SYSTEMMODAL, "Error", "Please ensure the relevant information has been entered correctly.")
				EndIf
		EndSwitch
	WEnd

	GUIDelete($hGUI) ; Delete the previous GUI and all controls.
EndFunc   ;==>Example







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