#NoEnv

objShell := ComObjCreate("WScript.Shell")
var := objShell.Exec("powercfg /list").StdOut.ReadAll()

str :=SubStr(var, InStr(var,"`n",,,3) + 1)
GUIDs:={}
Gui, Add, Button, w50 h40 gEditPowerPlan, Edit

Loop, Parse, str, "`n"
{
	if (A_LoopField = "")
		Continue
	guid:= SubStr(A_LoopField, 20, 36)
	powerPlanName:= SubStr(A_LoopField, 21+36+1)
	Gui, Add, Button, w150 h80 gButtonsFunc v%A_Index%, %powerPlanName%
	GUIDs.push(guid)
}

CoordMode, Mouse, Screen
MouseGetPos, Mx, My
SysGet, MWA_, MonitorWorkArea

null:=" "
Gui, Show, Hide
Gui, +alwaysontop lastfound
hGui := WinExist()
WinGetPos,,, W, H
Final_x := max(MWA_Left, min(Mx, MWA_Right - W))
Final_y := max(MWA_Top, min(My, MWA_Bottom - H))
Gui, Show, x%Final_x% y%Final_y%, %null%
;Gui, show, x2540 yCenter autosize,

~LButton::
MouseGetPos,,, hWinUM
if (hWinUM != hGui) 
{	
	ExitApp
}
return

ButtonsFunc(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
{	
	global GUIDs
    Gui Submit, NoHide
    GuiControlGet num, Name, % CtrlHwnd
    g:= % GUIDs[num]
    msg := "powercfg /S " . g
	Run, %msg% ,, hide
    ExitApp
}

EditPowerPlan(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
{
	Run, %ComSpec% /c control powercfg.cpl ,, hide
	GuiClose:
	GuiEscape:
	ExitApp
}

min(a, b) {
    Return, a < b ? a : b
}

max(a, b) {
    Return, a > b ? a : b
}