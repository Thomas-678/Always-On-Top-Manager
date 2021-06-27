#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleInstance
#persistent
; get always on top state
AOT(_id)
{
	WinGet, ExStyle, ExStyle, ahk_id %_id%
	if (ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST.
		return 1
	else
		return 0
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create the ListView
; 1st column contains empty data
Gui, Add, ListView, r15 w600 gMyListView, null|Top?|Title|pid|id
Gui, +AlwaysOnTop -SysMenu +LastFound
hGui := WinExist()

Menu, Tray, Click, 1
Menu, Tray, Add, Show GUI, RefreshListView
Menu, Tray, Default, Show GUI

Gosub UpdateExplorerPID ; explorer.exe has several useless hidden windows, need to ignore them in GUI
SetTimer, UpdateExplorerPID, 3600000 ; run this per 1 hour

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
~LButton::
MouseGetPos,,, hWinUM
if (hWinUM != hGui)
{
	GuiClose:
	Gui, Hide
	LV_Delete()
}
return

MyListView:
if (A_GuiEvent = "DoubleClick")
{
    LV_GetText(progName, A_EventInfo, 3)  
    LV_GetText(onTopID, A_EventInfo, 5) 
    ;WinSet, ExStyle, +0x8, ahk_id %onTopID% ;Non-working command
    WinSet, AlwaysOnTop,, ahk_id %onTopID%
    Gui, +AlwaysOnTop
    ;msgbox, You selected program: %progName%
    ;RefreshListView()
    LV_Modify(A_EventInfo, "Col2", AOT(onTopID))
}
return

UpdateExplorerPID:
winget, explorerPID, PID, ahk_exe Explorer.EXE
return

RefreshListView:
WinGet windows, List
Loop %windows%
{
	_id := windows%A_Index%
	WinGetTitle wt, ahk_id %_id%
	winget, _pid, PID, ahk_id %_id%
	if (explorerPID = _pid and (wt = "Program Manager" or wt = ""))
		continue
	LV_Add("", "", AOT(_id), wt, _pid, _id)
}
LV_ModifyCol(1, "0") ; Hide column (null) by resizing width to 0
LV_ModifyCol(2, "AutoHdr right")
LV_ModifyCol(3, "Auto Sort")
LV_ModifyCol(4, "AutoHdr")
LV_ModifyCol(5, "0") ; Hide column (id) by resizing width to 0
Gui, Show, x0 yCenter autosize
Gui, +AlwaysOnTop
return