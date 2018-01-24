/*
BEGIN COMMENTS


CREDIT:
kuangmk11 posted a wonderful AutoHotkey macro at this link:
http://mwomercs.com/forums/topic/134382-cant-you-just-macro-the-gauss/page__view__findpost__p__2751940
His macro was utilized as a base to build a Gauss overlay for MWO.


ProtoformX is the primary contributor to this project.


INSTRUCTIONS:
1.) Place the Gauss rifle in Weapon Group 2(Must be right mouse button).
2.) Place the PPC's or other weapons you want to fire with the Gauss rifle in Weapon Group 6.
3.) Launch the script and run MWO.  It doesn't matter which order you start them in.
4.) while MWO is active, press Ctrl+Alt+G to toggle on and off the overlay.  If MWO is not active,
    instead press Windows+Alt+G to toggle.  Hold the right mouse button to charge the Gauss and 
    use it just like normal.  On release, Weapon Group 6 will also fire.  Weapon fire sync will
    work whether the overlay is active or not.


PROGRESS BAR LEGEND:
Lime:    Weapons reloading status.
Blue:    Gauss charge remaining.
Yellow:  Charge status.




END COMMENTS
*/




#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%/B  ; Ensures a consistent starting directory.
#singleinstance Force


xMidScrn  := A_ScreenWidth //2
yMidScrn  := A_ScreenHeight //2
Gui1X     := xMidScrn - xMidScrn *.1
Gui1Y     := yMidScrn - yMidScrn *.15
Gui2X     := xMidScrn
Gui2Y     := yMidScrn
Charging  := 0
MyIndex1  := 0
MyIndex2  := 100
MyIndex3  := 100
Toggle    := 0
Recycling := 0
Charging  := 0
Charged   := 0
percent   := 0


Gui, Destroy
Gui, +AlwaysOnTop
Gui, Color, Black
Gui -Caption
Gui +ToolWindow
Gui, Add, Progress, vMyProgress1 h8 w130 cFACC2E Background2E2E2E xp+20 yp+130
Gui, Add, Progress, vMyProgress2 h8 w130 c2E9AFE Background2E2E2E yp-8
Gui, Add, Progress, Vertical vMyProgress3 h49 w8 cLime Background2E2E2E xp-22 yp-58
Gui, Show, Y%Gui1y% X%Gui1X%, MWO_Gauss_Overlay, NoActivate, Title of Window
WinSet, Transcolor, Black, ahk_class AutoHotkeyGUI
GuiControl,, MyProgress2, %MyIndex2%
GuiControl,, MyProgress3, %MyIndex3%
Gui, Hide
Return


;When in Windows press Windows+Alt+G to toggle the script on and off
#!G::
toggle:=!toggle ;toggles up and down states. 
  if toggle
    {
    Gui, Show 
    WinActivate MechWarrior Online
    }
  Else
    {
    Gui, Hide
    }
return


#IfWinActive MechWarrior Online


;When in MWO press Ctrl+Alt+G to toggle the script on and off
^!G:: 
toggle:=!toggle ;toggles up and down states. 
  if toggle
    {
    Gui, Show 
    WinActivate MechWarrior Online
    }
  Else
    {
    Gui, Hide
    }
return


Rbutton::
IF (Recycling == 0)
{
  Charging := 1
  Loop,1
  {
    Settimer, gCharge, 75
  }
}
Return


Rbutton up::
settimer, gWindow, off
if ((Charging == 0) and (charged == 1))
{
send, {6 down}
sleep, 25
send {6 up}
Recycling := 1
settimer, gRecycle, 185
MyIndex3 := 0
GuiControl, +CFACC2E, MyProgress3
GuiControl,, MyProgress3, %MyIndex3%
}
charged := 0
charging := 0
MyIndex1 := 0
MyIndex2 := 100
GuiControl,, MyProgress1, %MyIndex1%
GuiControl,, MyProgress2, %MyIndex2%
Return


gCharge:
Loop,1
{
  GetKeyState, state, Rbutton, P
  if state = U
   break
  MyIndex1 := MyIndex1 + 11.12
  GuiControl,, MyProgress1, %MyIndex1%
}
if MyIndex1 >= 100
{
settimer,gCharge,off
Charging := 0
Charged  := 1
GuiControl, +CRed, MyProgress1 ;RED
GuiControl, +CRed, MyProgress3 ;RED
GuiControl,, MyProgress1, %MyIndex1%
GuiControl,, MyProgress2, %MyIndex2%
GuiControl,, MyProgress3, %MyIndex3%
settimer, gWindow, 125
}
Return




gWindow:
Loop,1
{
GetKeyState, state, Rbutton, P
if state = U
   break
MyIndex2 := MyIndex2 - 11.12
GuiControl,, MyProgress2, %MyIndex2%
}
if MyIndex2 = 100
{
settimer, gRecycle, off
GuiControl, +CLime, MyProgress3
GuiControl,, MyProgress3, %MyIndex3%
Recycling := 0
}
Return
