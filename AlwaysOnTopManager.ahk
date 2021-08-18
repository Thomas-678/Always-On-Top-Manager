#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
ListLines Off ; minor optimization. Disable logging of recently executed lines
#singleInstance
#persistent
Menu, Tray, Icon, %A_WinDir%\System32\imageres.dll, 234
; Add ahk_class here if you want them excluded from the GUI
excludeClasses := ["MSO_BORDEREFFECT_WINDOW_CLASS", "WorkerW", "Shell_TrayWnd", "Progman"]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create ListView for the GUI
guiHidden := true
Gui, 1:Add, ListView, r15 w600 AltSubmit gMyListView, null|Top?|Title|pid|id|class
Gui, 1:+AlwaysOnTop -SysMenu +LastFound
hGui := WinExist()

; Create 2nd GUI that create a highlight border around selected window
Gui, 2:+Toolwindow
Gui, 2:Color, FF0000
Gui, 2:-Caption

Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Show GUI, RefreshListView
Menu, Tray, Standard
Menu, Tray, Default, Show GUI

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
~LButton::
if (guiHidden = true)
	return
MouseGetPos,,, hWinUM
if (hWinUM != hGui) 
{	
	; detected left click outside of GUI
	GuiClose:
	GuiEscape:
	Gui, 1:Hide
	LV_Delete()
	guiHidden := true
	return
} else
	Gui, 1:+AlwaysOnTop 
return

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Labels section
MyListView:
if (A_GuiEvent = "A" or A_GuiEvent = "RightClick") ; double click or right click to toggle on top state
{
    LV_GetText(onTopID, A_EventInfo, 5) 
    ;WinSet, ExStyle, +0x8, ahk_id %onTopID% ;Non-working command
    
    ; sometimes when the window is minimized, AOT state cannot be toggle
    ; create workaround
    WinGet, minState, MinMax, ahk_id %onTopID%
    if (AOT(onTopID) = 0 and minState = -1) ; not on top and minimized
	{
		WinActivate, ahk_id %onTopID%
		WinSet, AlwaysOnTop, On, ahk_id %onTopID%
	} else
	{
		WinSet, AlwaysOnTop, toggle, ahk_id %onTopID% ; toggle topmost state
	}
    
    Gui, 1:+AlwaysOnTop
    LV_Modify(A_EventInfo, "Col2", AOT(onTopID))
}
else if (A_GuiEvent = "Normal") ; single left click
{
	LV_GetText(highlightID, A_EventInfo, 5)
	try DrawRect(highlightID)
	Gui, 1:+AlwaysOnTop 
}
return

RefreshListView:
guiHidden := false
WinGet windows, List
Loop %windows%
{
	_id := windows%A_Index%
	WinGetTitle wt, ahk_id %_id%
	winget, _pid, PID, ahk_id %_id%
	WinGetClass, _class, ahk_id %_id%
	if (HasVal(excludeClasses, _class) != 0)
		continue ; filter out unwanted window
	LV_Add("", "", AOT(_id), wt, _pid, _id, _class)
}
LV_ModifyCol(1, "0") ; Hide column (null) by resizing width to 0
LV_ModifyCol(2, "AutoHdr right")
LV_ModifyCol(3, "Auto Sort")
LV_ModifyCol(4, "AutoHdr")
LV_ModifyCol(5, "0") ; Hide column (id) by resizing width to 0
Gui, 1:Show, x0 yCenter autosize
Gui, 1:+AlwaysOnTop
return

StopWindowHighlight:
Gui, 2:hide
return

;;;;;;;;;;;;;;;;;;;;;
; Functions section

; get always on top state
AOT(_id)
{
	WinGet, ExStyle, ExStyle, ahk_id %_id%
	if (ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST.
		return 1
	else
		return 0
}

; Draw lines around a window's edges
DrawRect(_id)
{
	b = 6 ;border thickness
	WinGetPos, x, y, w, h, ahk_id %_id%
	q:=w-b, z:=h-b
	; bring selected window on top without activating it
	; But if the window was minimized, AHK cannot bring it to front without activating it
	; this can interfere with double clicking on GUI, ie. need to click three times
	WinGet, minState, MinMax, ahk_id %_id%
	if (minState = -1) ; minimized
		WinActivate, ahk_id %_id%
		
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

; search given value's position in array
HasVal(haystack, needle) {
	for index, value in haystack
		if (value = needle)
			return index
	if !IsObject(haystack)
		throw Exception("Bad haystack!", -1, haystack)
	return 0 ; not found
}