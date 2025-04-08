



#include-once

Func OpenOrActivateWilcom()
    Local $bFound = False
    Local $aWinList = WinList()

    ; Tìm cửa sổ đã mở
    For $i = 1 To $aWinList[0][0]
        If StringInStr($aWinList[$i][0], "(Ultimate Special Edition)") Then
            WinSetState($aWinList[$i][0], "", @SW_RESTORE)
            WinActivate($aWinList[$i][0])
            WinWaitActive($aWinList[$i][0], "", 5)
            WinSetState($aWinList[$i][0], "", @SW_MAXIMIZE)
            $bFound = True
            ExitLoop
        EndIf
    Next

    ; Nếu không tìm thấy thì mở Wilcom và kiểm tra Auto Recovery
    If Not $bFound Then
        ; Mở Wilcom
        ShellExecute("Wilcom EmbroideryStudio e4.2.lnk", "", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Wilcom EmbroideryStudio e4.2")
    
        ; Chờ Wilcom chạy và xử lý 2 tình huống
        Local $iTimeout = 120
        Local $iElapsed = 0
    
        While $iElapsed < $iTimeout
            ; Ưu tiên xử lý nếu có Auto Recovery
            If WinExists("Auto Recovery") Then
                WinActivate("Auto Recovery")
                WinWaitActive("Auto Recovery", "", 5)
                ControlClick("Auto Recovery", "", "[CLASS:Button; INSTANCE:3]")
                ExitLoop
    
            ; Nếu không có Auto Recovery nhưng có (Ultimate Special Edition)
            ElseIf WinExists(" (Ultimate Special Edition)") Then
                WinActivate(" (Ultimate Special Edition)")
                WinWaitActive(" (Ultimate Special Edition)", "", 5)
               
                MouseClick("left", 528, 224, 1)
                MouseClick("left", 528, 224, 1)
                ExitLoop
            EndIf
    
            Sleep(1000)
            $iElapsed += 1
        WEnd
    EndIf
    
EndFunc
