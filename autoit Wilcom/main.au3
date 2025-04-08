
#include-once
#include "mod\openActiveWilCom.au3"
#include "mod\getFileDesign.au3"
#include "mod\reqToNodejs.au3"
 
OpenOrActivateWilcom() ; active hoặc open wilcom;
If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát
Local $pngInfo = GetFirstPngFromDesign()
Local $tenDesign = $pngInfo[0]
Local $linkDesign = $pngInfo[1]

; ✅ Đợi cửa sổ "Import Graphic"
MouseClick("left", 511, 65, 1)

WinWaitActive("Import Graphic", "", 5)
Sleep(300)
; ✅ Gõ đường dẫn ảnh
Send($linkDesign)
Sleep(300)
Send("{ENTER}")
Sleep(300)

	If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát


;~ click Graphic
	MouseClick("left", 443, 38, 1)
	Sleep(300)
;~ 	click prepare bitmap color
	MouseClick("left", 480, 242, 1)
	Sleep(300)
	If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát
	; ✅ Xử lý bảng Prepare Bitmap Colors
	If WinWaitActive("Prepare Bitmap Colors", "", 5) Then
	; Lấy số màu từ Static control
; Lấy số màu từ Static control (Instance 6)
		Local $colorCount = ControlGetText("Prepare Bitmap Colors", "", "[CLASS:Static; INSTANCE:6]")

		$colorCount = StringStripWS($colorCount, 3) ; loại khoảng trắng đầu/cuối
		$colorCount = Number($colorCount)
		
		If IsNumber($colorCount) And Number($colorCount) > 15 Then
			; Click vào ô nhập số màu 
			MouseClick("left", 530, 565, 1)
			Sleep(200)
			Send("^a")
			Send("15")
			

		EndIf
		If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát
		ControlClick("Prepare Bitmap Colors", "", "Button12")
	Else
		REQ_errWilcom("Không thấy bảng 'Prepare Bitmap Colors'")
	
		Exit
	EndIf
	If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát
	; ✅ Smart Design
	MouseClick("left", 443, 38, 1)
	Sleep(100)

	MouseClick("left", 458, 108, 1)
	Sleep(100)

	If WinWaitActive("Smart Design", "", 5) Then
		ControlClick("Smart Design", "", "Button1")
	Else
		REQ_errWilcom("Không thấy bảng 'Smart Design'")
		Exit
	EndIf

	If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát

	;~ chuyển chỉ sang tatami
	;~ Send("^a")
	;~ MouseClick("left", 780, 142, 1)
	;~ If Not _WaitForIdleCursor(15000) Then Exit     ; nếu quá lâu thì thoát

	; ✅ Xuất file DST
	Send("+e")

	WinWaitActive("Export Machine File", "", 5)

	Local $dstPath =@ScriptDir & "\export dst\Design1.dst";
	Send($dstPath)
	Sleep(300)
	Send("{ENTER}")
	Sleep(300)

	; ✅ Nếu xuất hiện hộp thoại hỏi lưu đè
	If WinWaitActive("Confirm Save As", "", 3) Then
		Send("!y")

	EndIf

	Sleep(500)
	Send("^a")      ; Ctrl + A → chọn tất cả
	Sleep(200)
	Send("{DELETE}") ; Nhấn Delete để xóa

	; ✅ Đọc số mũi thêu từ file DST
	Local $hFile = FileOpen($dstPath, 16)
	If $hFile = -1 Then
		REQ_errWilcom("khong mo duoc file DST'")
		Exit
	EndIf

	FileRead($hFile, 512) ; Bỏ header
	Local $stitchCount = 0
	While 1
		Local $chunk = FileRead($hFile, 3)
		If @error Or StringLen($chunk) < 3 Then ExitLoop
		If BinaryMid($chunk, 1, 3) = Binary("0x0000F3") Then ExitLoop
		$stitchCount += 1
	WEnd
	FileClose($hFile)

	; ✅ Báo kết quả

	REQ_StitchCount($stitchCount);








Func _WaitForIdleCursor($timeoutMs = 15000)
	Sleep(200)
	Local $timer = TimerInit()
	While MouseGetCursor() <> 2
		If TimerDiff($timer) > $timeoutMs Then
			REQ_errWilcom("qua thoi gian con tro xu ly'")
			Return False
		EndIf
		Sleep(200)
	WEnd
	Return True
EndFunc   ;==>_WaitForIdleCursor

