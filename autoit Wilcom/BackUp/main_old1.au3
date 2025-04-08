   
   #include-once
#include "mod\openActiveWilCom.au3"

OpenOrActivateWilcom() ; active hoặc open wilcom

MouseClick("left", 636, 65, 1)


; ✅ Đợi cửa sổ "Import Graphic"
WinWaitActive("Import Graphic", "", 5)
Sleep(300)
; ✅ Gõ đường dẫn ảnh
Send("C:\Users\Admin\Desktop\ts autoit wilcom\oke.png")
Sleep(300)
Send("{ENTER}")
Sleep(300)


   Local $title = "[REGEXPTITLE:(?i)Design1.*Tajima]"

    If WinExists($title) Then
    WinActivate($title)
    If WinWaitActive($title, "", 5) Then
        ; ✅ Click “Import Graphic...”
        MouseClick("left", 636, 65, 1)


        ; ✅ Đợi cửa sổ "Import Graphic"
        WinWaitActive("Import Graphic", "", 5)
    Sleep(300)
        ; ✅ Gõ đường dẫn ảnh
        Send("C:\Users\Admin\Desktop\ts autoit wilcom\oke.png")
        Sleep(300)
        Send("{ENTER}")
        Sleep(300)
    Else
        MsgBox(16, "❌ Lỗi", "Không thể kích hoạt Wilcom.")
        Exit
    EndIf

    If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát
    ; ✅ Click Graphic & Prepare Bitmap Colors

    ;~ click Graphic
    MouseClick("left", 443, 38, 1)
    Sleep(300)
    ;~ 	click prepare bitmap color
    MouseClick("left", 530, 242, 1)
    Sleep(300)
    If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát
    ; ✅ Xử lý bảng Prepare Bitmap Colors
    If WinWaitActive("Prepare Bitmap Colors", "", 5) Then
        ControlClick("Prepare Bitmap Colors", "", "Button12")
    Else
        MsgBox(16, "❌ Lỗi", "Không thấy bảng 'Prepare Bitmap Colors'")
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
        MsgBox(16, "❌ Lỗi", "Không thấy bảng 'Smart Design'")
        Exit
    EndIf

    If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát
    Send("^a")
    MouseClick("left", 780, 142, 1)
        If Not _WaitForIdleCursor(15000) Then Exit ; nếu quá lâu thì thoát
    ; ✅ Xuất file DST
    Send("+e")

    WinWaitActive("Export Machine File", "", 5)

    Local $dstPath = "C:\Users\Admin\Desktop\export dst\Design1.dst"
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
        MsgBox(16, "❌ Lỗi", "Không mở được file DST.")
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

    Local $url = "http://localhost:3458/notify"
    Local $data = "stitch=" & $stitchCount

    Local $oHttp = ObjCreate("WinHttp.WinHttpRequest.5.1")
    $oHttp.Open("POST", $url, False)
    $oHttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    $oHttp.Send($data)



    Else
    MsgBox(16, "❌ Không tìm thấy", "Không thấy cửa sổ Wilcom.")
    EndIf




    Func _WaitForIdleCursor($timeoutMs = 15000)
        Sleep(200)
    Local $timer = TimerInit()
    While MouseGetCursor() <> 2
        If TimerDiff($timer) > $timeoutMs Then
            MsgBox(16, "⏰ Timeout", "Quá thời gian chờ con trỏ xử lý xong.")
            Return False
        EndIf
        Sleep(200)
    WEnd
    Return True
    EndFunc

