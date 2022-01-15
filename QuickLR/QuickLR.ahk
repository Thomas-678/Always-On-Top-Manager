#NoEnv
ListLines Off
#MaxHotkeysPerInterval 1000
CoordMode, Mouse, Screen
; #Warn
Gui, Add, Button, x2 y-1 w60 h40 gLeft, Left
Gui, Add, Button, x62 y-1 w60 h40 gRight, Right
Gui, +AlwaysOnTop ToolWindow +hwndGuiHwnd
Gui, show, xCenter yCenter h40 w124

Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Show GUI, showGui
Menu, Tray, Standard
Menu, Tray, Default, Show GUI

return

Send_bg(key)
{
targetWin:= GetTargetWin()
ControlFocus,, ahk_id %targetWin% 
ControlSend,,%key%, ahk_id %targetWin% 
Gui, +AlwaysOnTop
return
}
Left:
Send_bg("{left}")
return

Right:
Send_bg("{Right}")
return

#if BoundCheck()
~WheelUp::Send_bg("{Left}")
~WheelDown::Send_bg("{Right}")
#if
BoundCheck()
{
global GuiHwnd
MouseGetPos,,,id
if (id= GuiHWnd)
	return True
Else
	return False
}

GuiClose:
Gui, Hide
return

showGui:
Gui, Show
return

WindowFromPos(X, Y, DetectHidden := False) {
   ; CWP_ALL = 0x0000, CWP_SKIPINVISIBLE = 0x0001
   Return DllCall("ChildWindowFromPointEx", "Ptr", DllCall("GetDesktopWindow", "UPtr")
                                          , "Int64", (X & 0xFFFFFFFF) | ((Y & 0xFFFFFFFF) << 32)
                                          , "UInt", !DetectHidden
                                          , "UPtr")
}

GetTargetWin()
{
global GuiHwnd
WinGetPos, x, y,,,ahk_id %GuiHwnd%
x-=1, y-=1
if x<0 
	x:=0
if y<0 
	y:=0
return targetWin:= WindowFromPos(x,y)
}