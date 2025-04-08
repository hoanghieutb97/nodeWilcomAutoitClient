Func GetFirstPngFromDesign()
    Local $designDir = @ScriptDir & "\design"
    Local $search = FileFindFirstFile($designDir & "\*.png")

    If $search = -1 Then Return SetError(1, 0, 0)

    Local $firstPng = FileFindNextFile($search)
    FileClose($search)

    If $firstPng = "" Then Return SetError(2, 0, 0)

    Local $result[2]
    $result[0] = $firstPng
    $result[1] = $designDir & "\" & $firstPng

    Return $result
EndFunc
