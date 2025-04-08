Func REQ_StitchCount($stitchCount)
    Local $url = "http://localhost:3458/notify"
    Local $data = "data=" & $stitchCount

    Local $oHttp = ObjCreate("WinHttp.WinHttpRequest.5.1")
    $oHttp.Open("POST", $url, False)
    $oHttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    $oHttp.Send($data)
EndFunc


Func REQ_errWilcom($typeErr)
    Local $url = "http://localhost:3458/errWilcom"
    Local $data = "data=" & $typeErr

    Local $oHttp = ObjCreate("WinHttp.WinHttpRequest.5.1")
    $oHttp.Open("POST", $url, False)
    $oHttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    $oHttp.Send($data)
    
    Sleep(500)
	Send("^a")      ; Ctrl + A → chọn tất cả
	Sleep(200)
	Send("{DELETE}") ; Nhấn Delete để xóa
EndFunc
