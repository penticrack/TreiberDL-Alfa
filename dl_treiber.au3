#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         penticrack

 Script Function:
	Herunterladen der Treiber von Toshiba Seite

#ce ----------------------------------------------------------------------------

;MS Dom Doku
;https://msdn.microsoft.com/en-us/library/ms535877%28v=vs.85%29.aspx
#include <GuiMenu.au3>
#include <GUIConstants.au3>
#include <INet.au3>
#include <InetConstants.au3>
#include <IE.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <GuiStatusBar.au3>
#include <ProgressConstants.au3>
#include <GuiComboBox.au3>
#include <String.au3>
#Include <WinAPIEx.au3>


Global $idDL = 1000
Global $arrOSSelect[1] ;Combobox der OS auf der Toshiba Seite


#Region ### START Koda GUI section ### 
$Form1 = GUICreate("Treiber-Downloader", 982, 667, 193, 126)
Global $List1 = _GUICtrlListView_Create($Form1,"", 40, 184, 929, 357,BitOR($LVS_EDITLABELS, $LVS_REPORT))
_GUICtrlListView_SetExtendedListViewStyle($List1, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))

$combo_OS = GUICtrlCreateCombo("", 40, 152, 281, 25)

GUICtrlSetState(-1, $GUI_HIDE)

$txtTreiberseite = GUICtrlCreateInput("", 40, 120, 705, 21)
$txtSerial = GUICtrlCreateInput("XD185453C", 552, 56, 193, 21)
$Label1 = GUICtrlCreateLabel("Toshiba Treiberseite:", 40, 96, 103, 17)
$Label2 = GUICtrlCreateLabel("Treiber auf der Toshibaseite suchen und dann bei der Navigation unten die Seitenlinks benutzen",  40, 16, 459, 17)
$Label3 = GUICtrlCreateLabel("um die Vollständige Treiberurl zu erhalten",  40, 32, 197, 17)
$btnDL = GUICtrlCreateButton("Start Download",  40, 576, 225, 33, 0)
$Button1 = GUICtrlCreateButton("Suche Treiber", 776, 120, 177, 22, 0)
$Button2 = GUICtrlCreateButton("Suche Serien-Nr.", 776, 56, 177, 22, 0)
$lbl_gefTreiber = GUICtrlCreateLabel("Gefundene Treiber: ", 40, 560, 219, 17)


Local $aParts[3] = [100, 380, -1]
$StatusBar1 = _GUICtrlStatusBar_Create($Form1,$aParts)
_GUICtrlStatusBar_SetText($StatusBar1, "Status")
$progress = GUICtrlCreateProgress(0, 0, -1, -1, $PBS_SMOOTH)
GUICtrlSetColor($progress, 0xff0000)
_GUICtrlStatusBar_EmbedControl($StatusBar1, 1, GUICtrlGetHandle($progress))


GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")


GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


HttpSetUserAgent("Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.1.6) Gecko/20091201 Firefox/3.5.6 GTB6 (.NET CLR 2.0.50727)")
;$filename = HTTPFileName("URL")


While 1

	$nMsg = GUIGetMsg()
	Switch $nMsg
	Case $GUI_EVENT_CLOSE
		Exit
		Case $btnDL
			disable_enable_GUICTRL(0)
			_StartDownload()
			disable_enable_GUICTRL(1)
		Case $Button1
			disable_enable_GUICTRL(0)
			setList1(GUICtrlRead($txtTreiberseite))
			disable_enable_GUICTRL(1)
		Case $Button2
			disable_enable_GUICTRL(0)
			$Treiber_URL = sucheSeriennr_setzeTreiberseite(GUICtrlRead($txtSerial))
			;Setze Treiberseite
			GUICtrlSetData($txtTreiberseite,$Treiber_URL)
			;hole Treiber von Treiberseite
			setList1(GUICtrlRead($txtTreiberseite))
			disable_enable_GUICTRL(1)
		Case $combo_OS
			disable_enable_GUICTRL(0)
			ComboOSChange()
			disable_enable_GUICTRL(1)
	EndSwitch
WEnd





;$s_URL = "http://www.toshiba.de/innovation/download_drivers_bios_smp.jsp?service=DE&selCategory=2&selFamily=2&selSeries=178&selProduct=7892&selShortMod=3934&language=17&selOS=46&selType=all&yearupload=&monthupload=&dayupload=&useDate=null&mode=allMachines&search=&action=search&macId=&country=12&page=1"
;s_SN = "XD185453C"


func sucheSeriennr_setzeTreiberseite($SerienNr)

	_GUICtrlStatusBar_SetText($StatusBar1, "Hole Treiberseite...")

	$oSubmit = ""




		While 1=1
			;öffne Webseite zur Eingabe der Seriennummer
			$Website = _IECreate("http://www.toshiba.de/innovation/generic/SUPPORT_PORTAL/",0,0)

			If @error <> 0 Then

				MsgBox(0,"Fehler" , "Fehlercode bei Seitenladen: " & @error)
				$Website = _IECreate("http://www.toshiba.de/innovation/generic/SUPPORT_PORTAL/",0,0)
			Else
				ExitLoop
			EndIf

		WEnd


		;setze Seriennummer in Inputfeld
		Local $oForm = _IEGetObjByName($Website, "serialNumber")
		_IEFormElementSetValue($oForm, GUICtrlRead($txtSerial))

		;suche Submitbutton
		Local $oSubmit = _IETagNameGetCollection($Website, "div")




	For $oInput In $oSubmit
		;$sTxt &= $oInput.type & @CRLF
		;finde den Bereich für die Seriennummerneingabe
		If $oInput.className = "portlet_content_column column_one serial_number" then

			;suche in dem Bereich den Button
			Local $oCollection = _IETagNameGetCollection($oInput, "input")
			For $oElement in $oCollection
				If $oElement.Type = "button" Then
					_IEAction($oElement, 'click')
					;_IELoadWait($Website)

					;warten bis seite geladen ist
					While 1=1
						Sleep(600)
						Local $javascr_collection = _IETagNameGetCollection($Website, "script")
						for $script in $javascr_collection

							If $script.Type = "text/javascript" Then
								If StringInStr($script.innerText,"Treiber") Then
									;Iframe definition gefunden, Seite ist also geladen

									ExitLoop 2
								EndIf
							EndIf

						next
					WEnd

					;Seite geladen
					;Msgbox(0,"",$script.innerText)
					;msgbox(0,"",StringRegExp($script.innerText,".*,name:.Treiber.,url:"))
					;MsgBox(0,"",_ArrayDisplay(_StringBetween($script.innerText,"name:",",type")))
					For $endURL in _StringBetween(StringReplace($script.innerText,'"',''),"name:",",type")
						;_ArrayDisplay(StringSplit($endURL,","))
						If StringSplit($endURL,",")[1] = "Treiber" Then
							$endURL2 = StringReplace(StringSplit($endURL,",")[2],"url:","")
							;Msgbox(0,"",$endURL2)
							$endURL3 = "http://www.toshiba.de" & $endURL2
							_IEQuit($Website)
							return $endURL3

						EndIf

					Next


				EndIf


			Next




		EndIf
	Next





EndFunc


func _StartDownload()


	 $ListItemCount = _GUICtrlListView_GetItemCount($List1) -1




	For $item = 0 to $ListItemCount
		$aItemText = _GUICtrlListView_GetItem($List1,$item,6)
		$aItemOS = _GUICtrlListView_GetItem($List1,$item,3)
		$aItemTyp = _GUICtrlListView_GetItem($List1,$item,1)
		$aItemFirma = _GUICtrlListView_GetItem($List1,$item,2)
		$aItemVersion = _GUICtrlListView_GetItem($List1,$item,4)
		$aItemDatum = _GUICtrlListView_GetItem($List1,$item,0)
		$aItemDatum = StringReplace($aItemDatum[3], "/","-")

		$aUnterordner = $aItemTyp[3] & "(" & $aItemFirma[3] & ")" & "-" & $aItemVersion[3]
		$aUnterordner = StringStripWS( StringReplace($aUnterordner, "\",""), 8 )



		;lege OS VErsion Verzeichnis an
		If DirGetSize(@ScriptDir & "\" & $aItemOS[3]) <> -1 Then
        ;MsgBox($MB_SYSTEMMODAL, "", "Directory already exists!")
		Else
			DirCreate(@ScriptDir & "\" & $aItemOS[3])
		EndIf

		;lege Treiberverzeichnis an
		;lege OS VErsion Verzeichnis an
		If DirGetSize(@ScriptDir & "\" & $aItemOS[3] & "\" &  $aUnterordner ) <> -1 Then
        ;MsgBox($MB_SYSTEMMODAL, "", "Directory already exists!")
		Else
			DirCreate(@ScriptDir & "\" & $aItemOS[3] & "\" & $aUnterordner)
		EndIf

		;msgbox(0,"",$aItemText[3])
		;msgbox(0,"",StringTrimLeft($aItemText[3],StringInStr($aItemText[3],"/",Default,-1)))
		$file = @ScriptDir & "\" & $aItemOS[3] & "\" & $aUnterordner & "\" & StringTrimLeft($aItemText[3],StringInStr($aItemText[3],"/",Default,-1))


		_GUICtrlStatusBar_SetText($StatusBar1, "TreiberDL: " & $item + 1  & "/" & $ListItemCount)

		$hDownload = InetGet($aItemText[3], $file, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

		;MsgBox(0,"",@error)

		$DLSize = InetGetSize($aItemText[3])

		;Zeige Status des DL alle 500ms an
		Do
			Sleep(500)

			$percent = (InetGetInfo($hDownload,$INET_DOWNLOADREAD) * 100)/$DLSize
			GUICtrlSetData($progress, $percent)
			;msgbox(0,"",InetGetInfo($hDownload,$INET_DOWNLOADREAD))
		Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

	    Local $aData = InetGetInfo($hDownload)
		If @error Then
		; Display details about the downloaded file.
			MsgBox(0, "", "Bytes read: " & $aData[$INET_DOWNLOADREAD] & @CRLF & _
            "Size: " & $aData[$INET_DOWNLOADSIZE] & @CRLF & _
            "Complete: " & $aData[$INET_DOWNLOADCOMPLETE] & @CRLF & _
            "successful: " & $aData[$INET_DOWNLOADSUCCESS] & @CRLF & _
            "@error: " & $aData[$INET_DOWNLOADERROR] & @CRLF & _
            "@extended: " & $aData[$INET_DOWNLOADEXTENDED] & @CRLF)

		EndIf


		    ; Close the handle returned by InetGet.
		InetClose($hDownload)

	Next


EndFunc

Func getTreiberTableToshiba($s_URL)

		;Toshiba Treiberseite
	;$s_URL = "http://www.toshiba.de/innovation/download_drivers_bios_smp.jsp?service=DE&selCategory=2&selFamily=2&selSeries=178&selProduct=7892&selShortMod=3934&language=17&selOS=46&selType=all&yearupload=&monthupload=&dayupload=&useDate=null&mode=allMachines&search=&action=search&macId=&country=12&page=1"

	$arrTreiberGesamt=""



	While $s_URL <> ""




		$Website = _IECreate($s_URL,0,0)


		;Liste Tabellen der Seite und Suche nach der Treibertabelle
		$oTable = _IETableGetCollection($Website)
		$iNumTables = @extended



		;Fülle Combobox mit möglichen OS und setze Combobox auf gesetzten Wert der Webseite
		Global $oSelect = _IEGetObjByName($Website, "selOS")
		;MsgBox(0, "Form Element Value", _IEFormElementGetValue($oSelect))
		$option = _IEFormElementGetValue($oSelect)
		   ;MsgBox($MB_SYSTEMMODAL, "state", StringFormat("GUICtrlRead=%d\nGUICtrlGetState=%d", GUICtrlRead($combo_OS), GUICtrlGetState($combo_OS)) & "Bitor: " & BitOR($GUI_HIDE,$GUI_ENABLE))
		If GUICtrlGetState($combo_OS) = BitOR($GUI_HIDE,$GUI_ENABLE) Then

			For $sample in $oSelect
				_ArrayAdd($arrOSSelect,$sample.innerText & "|"  & $sample.Value)
				;GUICtrlSetData($combo_OS, $sample.innerText & "|" & $sample.Value)
				GUICtrlSetData($combo_OS, $sample.innerText)
				;msgbox(0,"", "Value: "& $sample.Value & @CRLF &  "innertext: "  & $sample.innerText)
			Next

			GUICtrlSetState($combo_OS, $GUI_SHOW)
			;_ArrayDisplay($arrOSSelect)
		EndIf

		$iSelected = $oSelect.selectedIndex
		;MsgBox(0,"","Seitencombo: " & $oSelect.options($iSelected).text)
		_GUICtrlComboBox_SetCurSel($combo_OS, $iSelected)
		;$sSelectBox = _IEPropertyGet ($oSelect, "innertext")
		;MsgBox(0, "Form Element Value", _IEFormElementGetValue($oSelect))
		;MsgBox(0,"",$sSelectBox)


		For $Tables = 0 to $iNumTables
			$oTableNr = _IETableGetCollection($Website,$Tables)
			$aTableData = _IETableWriteToArray($oTableNr)
			;msgbox(0,"",ubound($aTableData))



			;nur gefüllte Tabellen benutzen
			if IsArray($aTableData) and Ubound($aTableData) > 0 then
				;MsgBox(0,"",$aTableData[0][0])

				;gesuchte Tabelle enthält die Treiberinformationen
				if StringInStr($aTableData[0][0], "Gefundene Treiber") Then
					;_ArrayDisplay($aTableData)
					Global $TreiberGesamtAnzahl = StringStripWS(StringReplace($aTableData[0][0],"Gefundene Treiber",""),8)
					GUICtrlSetData($lbl_gefTreiber, Ubound($arrTreiberGesamt) & "/"& $aTableData[0][0])



					;Tausche Reihen und Spalten
					_ArrayInvert($aTableData)

					;lösche Zeile mit Anzahl gefundene Treiber
					_ArrayDelete($aTableData,0)

					$arrUeberschriften = _ArrayExtract($aTableData,0,0)

					;Lösche Zeile mit überschriften
					_ArrayDelete($aTableData,0)



					;Hole Download-Links der Treiber und fülle diese in die letzte Spalte
					For $LinkNr = 0 to Ubound($aTableData,1) - 1
						$oTableNr_links = _IETableGetCollection($Website,$Tables + $LinkNr + 1)
						;msgbox(0,"",Ubound($aTableData,1) - 1)
						;hole in der Tabelle die Links raus (der erste Link reicht)
						$oLinks = _IETagNameGetCollection($oTableNr_links,"a",1)
						;MsgBox(0,"","Anzahl links: " & @extended)

						$aTableData[$LinkNr][6] = $oLinks.href

					Next

					;MsgBox(0,"","Linksnr: " & $LinkNr)

					If IsArray($arrTreiberGesamt) Then

						_ArrayConcatenate($arrTreiberGesamt,$aTableData)
					Else
						;Ausgangsarray ist wohl noch leer

						_ArrayConcatenate($arrUeberschriften,$aTableData)

						$arrTreiberGesamt = $arrUeberschriften

					EndIf

					;_ArrayDisplay($arrTreiberGesamt)


				EndIf

						_GUICtrlStatusBar_SetText($StatusBar1, "Hole Treiber ->")



						;Suche die Navigationslinks
						$oLinks = _IETagNameGetCollection($oTableNr,"a")
						$NaviLinkCount = @extended

						$LinkCounter = 0
						;gehe die gefundenen Links durch
						for $text in $oLinks

							;welcher Link wird gerade betrachtet
							$LinkCounter = $LinkCounter + 1


							;Seite "weiter" gefunden
							If StringLeft($text.innerText,6) = "Weiter" Then

								;MsgBox(0,"",$text.href)
								$s_URL = $text.href
								ExitLoop 2

							Elseif StringIsDigit($text.innerText) And $text.href = ""  And $NaviLinkCount = $LinkCounter Then
							;falls am ende der Navigationszahlen ohne "Weiter" Link, dann beenden
								;MsgBox(0,"","innertext: " & $text.innerText & "href " & $text.href & " <<ende>>")
								$s_URL = ""

							Elseif StringIsDigit($text.innerText) And $text.style.color = "red" Then
							;gewählte Seitenzahl ist rot

								$percent = (Ubound($arrTreiberGesamt) * 100)/$TreiberGesamtAnzahl
								;MsgBox(0,"","Statusprozent: " & $percent & @CRLF & "$LinkCounter: " & $LinkCounter & @CRLF & "$NaviLinkCount" & $NaviLinkCount)
								GUICtrlSetData($progress, $percent)


							Else
								;irgendwas ist schief gegangen oder es gibt nur eine Seite, dann gibt es keine Navigation
								;MsgBox(0,"","Linkcounter: " & $LinkCounter & " innertext: " & $text.innerText & " href: " & $text.href)

								$s_URL = ""



							EndIf

						Next

			EndIf


		Next




		_IEQuit($Website)


	WEnd

	GUICtrlSetData($lbl_gefTreiber, Ubound($arrTreiberGesamt) - 1 & "/"& $TreiberGesamtAnzahl & " Gefundene Treiber")
	GUICtrlSetData($progress, 100)
	return $arrTreiberGesamt

EndFunc


func setList1($s_URL)


	$arrTreiberliste = getTreiberTableToshiba($s_URL)
	;_ArrayDisplay($arrTreiberliste)


	;Listview und dessen Spalten vor einfügen leeren
	_GUICtrlListView_DeleteAllItems ( $List1 )
	For $iColumn = 1 to _GUICtrlListView_GetColumnCount( $List1 )
		_GUICtrlListView_DeleteColumn ( $List1, 0 )
	Next


	;_ArrayDisplay($arrTreiberliste)

	;Spaltenüberschriften setzen
	For $i=0 to Ubound($arrTreiberliste,2)-1
		;msgbox(0,"",$arrTreiberliste[1][$i])
		_GUICtrlListView_AddColumn($List1,$arrTreiberliste[0][$i])
	Next

	;die ersten Zeile löschen, weil dort die Überschriften und gefundenen Einträge stehen

	_ArrayDelete($arrTreiberliste,0)


	;letzte Zeile löschen, da leer



	;Treiberlistenarray in Listview einfügen
	_GUICtrlListView_AddArray($List1, $arrTreiberliste)

	;Spaltenbreiten einstellen
	For $coulumncount = 0 to _GUICtrlListView_GetColumnCount ($List1) - 1
		_GUICtrlListView_SetColumnWidth($List1, $coulumncount, $LVSCW_AUTOSIZE)
	Next

	_GUICtrlStatusBar_SetText($StatusBar1, "Fertig.")


EndFunc


Func ComboOSChange()




	$OSindex = _ArraySearch($arrOSSelect,GUICtrlRead($combo_OS))
				;Msgbox(0,"",$arrOSSelect[$OSindex + 1])

	$oldURL = GUICtrlRead($txtTreiberseite)

	;umbauen der URL
	If StringInStr($oldURL,"selOS=") Then
		$ospos = StringInStr($oldURL,"selOS=")
		$endpos = StringInStr($oldURL,"&",0,1,$ospos)
		$newURL = StringReplace($oldURL,StringMid($oldURL,$ospos,$endpos - $ospos), "selOS=" & $arrOSSelect[$OSindex + 1])

	Else

		$newURL = Stringreplace(StringReplace($oldURL,"&include=true&banner_id=SMP_TAB_4",""),"download_drivers_bios.jsp","download_drivers_bios_smp.jsp") & "&selOS=" &  $arrOSSelect[$OSindex + 1]
		;MsgBox(0,"kein selOS gefunden!!!",$oldURL & @CRLF & "neu: " & $newURL)

	EndIf


	;MsgBox(0,"","Aufruf $newURL: " & $newURL & @CRLF & "$oldURL: " & $oldURL)
	setList1($newURL)

	;MsgBox(0,"","$ospos: " & $ospos & @CRLF & "$endpos: " & $endpos)
	;MsgBox(0,"", StringMid($oldURL,$ospos,$endpos - $ospos))





;$s_URL = "http://www.toshiba.de/innovation/download_drivers_bios_smp.jsp?service=DE&selCategory=2&selFamily=2&selSeries=178&selProduct=7892&selShortMod=3934&language=17&selOS=46&selType=all&yearupload=&monthupload=&dayupload=&useDate=null&mode=allMachines&search=&action=search&macId=&country=12&page=1"
EndFunc



Func ListView_RClick()
    Local $aHit




    $aHit = _GUICtrlListView_SubItemHitTest($List1)
    If ($aHit[0] <> -1) Then
        ; Create a standard popup menu
        ; -------------------- To Do --------------------
        $hMenu = _GUICtrlMenu_CreatePopup()


        _GUICtrlMenu_AddMenuItem($hMenu, "Download", $idDL)

		$clickcheck = _GUICtrlMenu_TrackPopupMenu($hMenu, $List1, -1, -1, 1, 1, 2)
        Switch $clickcheck

            Case $idDL
                ;_DebugPrint("Info: " & StringFormat("Item, SubItem [%d, %d]", $aHit[0], $aHit[1]))
				;MsgBox(0,"", "idDL: " & $idDL & @CRLF & _GUICtrlListView_GetItem($List1,$aHit[0],6)[3])
				$DLDateiName = _GUICtrlListView_GetItem($List1,$aHit[0],6)[3]
				$savedir = FileSelectFolder("Speichern unter...","",5,@ScriptDir)
				$file = $savedir & "\" & StringTrimLeft($DLDateiName,StringInStr($DLDateiName,"/",Default,-1))
				$DLsize1 = InetGetSize($DLDateiName)
				_GUICtrlStatusBar_SetText($StatusBar1, "Lade... ")
				$hDownload = InetGet($DLDateiName, $file, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
				;Zeige Status des DL alle 500ms an
				Do
					Sleep(500)

					$percent = (InetGetInfo($hDownload,$INET_DOWNLOADREAD) * 100)/$DLsize1
					GUICtrlSetData($progress, $percent)
					_GUICtrlStatusBar_SetText($StatusBar1, InetGetInfo($hDownload,$INET_DOWNLOADREAD)/1024 & " KBytes")
					;msgbox(0,"",InetGetInfo($hDownload,$INET_DOWNLOADREAD))
				Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
				_GUICtrlStatusBar_SetText($StatusBar1, "Fertig.")

        EndSwitch



		_GUICtrlMenu_DestroyMenu($hMenu)
    EndIf
EndFunc   ;==>ListView_RClick


Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
    $hWndListView = $List1
    If Not IsHWnd($List1) Then $hWndListView = GUICtrlGetHandle($List1)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    ;$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
                    ListView_RClick()
                    Return 0
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func _DebugPrint($s_text, $line = @ScriptLineNumber)
    ConsoleWrite( _
            "!===========================================================" & @LF & _
            "+======================================================" & @LF & _
            "-->Line(" & StringFormat("%04d", $line) & "):" & @TAB & $s_text & @LF & _
            "+======================================================" & @LF)
EndFunc   ;==>_DebugPrint





Func disable_enable_GUICTRL($Status)

	If $Status = 0 Then
		$SetStatus = $GUI_DISABLE
	Else
		$SetStatus = $GUI_ENABLE
	EndIf


    $Data = _WinAPI_EnumChildWindows($Form1)
	;_ArrayDisplay($Data)

    If IsArray($Data) Then
        For $i = 1 To $Data[0][0]

			If $Data[$i][1] = "Button"  Or $Data[$i][1] = "Edit" Then
				GUICtrlSetState(_WinAPI_GetDlgCtrlID($Data[$i][0]), $SetStatus)
			EndIf
        Next
    EndIf



EndFunc




Func _ArrayInvert (ByRef $Array1)   ;Rotates or inverts the array so columns become rows and rows columns
    Local $a1Rows = Ubound($Array1, 1)
    Local $a1Columns = Ubound($Array1,2)
    Local $Output [$a1Columns] [$a1Rows]
    For $y = 0 to $a1Rows -1
        For $x = 0 to $a1Columns -1
        $Output [$x][$y] = $Array1 [$y][$x]
        Next
    Next
$Array1=$Output
EndFunc


Func HTTPFileName($sUrl)
    $oHTTP = ObjCreate('winhttp.winhttprequest.5.1')
    $oHTTP.Open('POST', $sUrl, 1)
    $oHTTP.SetRequestHeader('Content-Type','application/x-www-form-urlencoded')
    $oHTTP.Send()
    $oHTTP.WaitForResponse
    $ContentDisposition = $oHTTP.GetResponseHeader("Content-Disposition:filename")
    ;ConsoleWrite($ContentDisposition & @CRLF)
    $array = StringRegExp($ContentDisposition, 'filename="(.*)"',3)
    ;ConsoleWrite($array[0] & @CRLF)
;ConsoleWrite($oHTTP.GetAllResponseHeaders())
    Return $array[0]
EndFunc
