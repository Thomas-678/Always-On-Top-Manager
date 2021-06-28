#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleInstance
#persistent
Menu, Tray, Icon, %A_WinDir%\System32\imageres.dll, 234
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
Gui, 1:Add, ListView, r15 w600 AltSubmit gMyListView, null|Top?|Title|pid|id
Gui, 1:+AlwaysOnTop -SysMenu +LastFound
hGui := WinExist()

; Create 2nd GUI that create highlight border around a window
Gui, 2:+Toolwindow
Gui, 2:Color, FF0000
Gui, 2:-Caption

Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Show GUI, RefreshListView
Menu, Tray, Standard
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
	GuiEscape:
	Gui, 1:Hide
	LV_Delete()
} else
	Gui, 1:+AlwaysOnTop
return

MyListView:
if (A_GuiEvent = "A" or A_GuiEvent = "RightClick") ; double click or right click
{
    LV_GetText(progName, A_EventInfo, 3)  
    LV_GetText(onTopID, A_EventInfo, 5) 
    ;WinSet, ExStyle, +0x8, ahk_id %onTopID% ;Non-working command
    WinSet, AlwaysOnTop,, ahk_id %onTopID% ; toggle topmost state
    Gui, 1:+AlwaysOnTop
    ;msgbox, You selected program: %progName%
    ;RefreshListView()
    LV_Modify(A_EventInfo, "Col2", AOT(onTopID))
}
else if (A_GuiEvent = "Normal") ; single left click
{
	LV_GetText(highlightID, A_EventInfo, 5)
	try DrawRect(highlightID)
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
Gui, 1:Show, x0 yCenter autosize
Gui, 1:+AlwaysOnTop
return

DrawRect(_id)
{
	b = 6 ;border thickness
	WinGetPos, x, y, w, h, ahk_id %_id%
	q:=w-b, z:=h-b 
	;bring selected window on top without activating it
	if (AOT(_id) = 0)
	{
		WinSet, AlwaysOnTop, On, ahk_id %_id%
		WinSet, AlwaysOnTop, Off, ahk_id %_id%
	} else
	{
		WinSet, Top,, ahk_id %_id%
	}
	Gui, 2:+AlwaysOnTop +Lastfound
	WinSet, Region, 0-0 %w%-0 %w%-%h% 0-%h% 0-0  %b%-%b% %q%-%b% %q%-%z% %b%-%z% %b%-%b%
	Gui, 2:Show, w%w% h%h% x%x% y%y% NoActivate
	SetTimer, StopWindowHighlight, -1000
	;prevent selected window from covering this GUI
	Gui, 1:+AlwaysOnTop
}
StopWindowHighlight:
Gui, 2:hide
return