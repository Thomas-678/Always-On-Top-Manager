#NoEnv
ListLines Off
#MaxHotkeysPerInterval 1000
; #Warn
Gui, Add, Button, x2 y-1 w60 h40 gLeft, Left
Gui, Add, Button, x62 y-1 w60 h40 gRight, Right
Gui, +AlwaysOnTop ToolWindow +hwndGuiHwnd
Gui, show, xCenter yCenter h40 w127

Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Show GUI, showGui
Menu, Tray, Standard
Menu, Tray, Default, Show GUI

return

Send_bg:
Gosub GetTargetWin
ControlFocus,, ahk_id %targetWin% 
ControlSend,,%key%, ahk_id %targetWin% 
Gui, +AlwaysOnTop
return

Left:
key:="{left}"
Gosub Send_bg
return

Right:
key:="{Right}"
Gosub Send_bg
return

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

GetTargetWin:
WinGetPos, x, y,,,ahk_id %GuiHwnd%
x-=1, y-=1
if x<0 
	x:=0
if y<0 
	y:=0
targetWin:= WindowFromPos(x,y)
return