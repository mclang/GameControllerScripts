/*
BEGIN COMMENTS
DESCRIPTION:
This script enables you to fire the gauss rifle with one click. The loading
and releasing of the weapons happens automaticly after the first click. The
gauss will fire when it is fully charged. You have NO option to hold the shot
back or delay it, when you trigger this script to shoot the weapon.
 
CREDITS:
This script is heavily based on the the script GaussOverlay from ProtoformX.
You can find it here:
https://www.mechspecs.com/threads/gauss-overlay-macro.5945/
His script enabled you to fire gauss rifle and PPC on the release of the
the gauss rifle.
Some of basic timings I got out of the macro from kuangmk11:
http://mwomercs.com/forums/topic/134382-cant-you-just-macro-the-gauss/page__st__40__p__2751940#entry2751940
 
INSTRUCTIONS:
1.) Place the Gauss rifle in Weapon Group 6. But you can switch the weapon
        group in the variable block for finetuning further down in this script.
2.) Launch the script and run MWO. It doesn't matter which order you start
        them in.
3.) while MWO is active, press Ctrl+Alt+G to toggle on and off this macro.
        If MWO is not active, instead press Windows+Alt+G to toggle.
4.) When you hold down the right mous button, the gauss rifle will fire
        repeatedly shot after shot until you relaese the button.
 
PROGRESS BAR LEGEND:
Red:     Gauss recycling status
Yellow:  Charge status.
END COMMENTS
*/
; Comments in AutoHotKey are started with a semicolon or the traditional
; stars and slashes as in the header.
; Recommended for performance and compatibility with future AutoHotkey
; releases.
#NoEnv
; Recommended for catching common errors.
#Warn
; Recommended for new scripts due to its superior speed and reliability.
SendMode Input
; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%/B
; Determines whether a script is allowed to run again when it is already
; running.
; The word FORCE skips the dialog box and replaces the old instance
; automatically, which is similar in effect to the Reload command.
#singleinstance Force
; #############################################################################
; VARIABLES FOR FINE TUNING
;
; How long you have to press the key or mouse button down to fully charge
; your gauss rifle.
; 850 is a little bit too short. shoots sometimes, but not everytime.
; 900 fires every time succesfully
; 880 fires every time succesfully
; 870 fires every time succesfully
; 860 fires every time succesfully
ChargeTime := 855
; How long your gauss rifle needs to recycle, before beeing charged again.
RecycleTime := 5000
; The weapon group to which the gauss is assigned
GaussWeaponGroup := "6"
; The refresh rate for the GUI progress bars. This is a frames per second
; value. In the original macro the function to refresh the gui was called
; every 75ms. Thats translates to 13,333 FPS (1000 / 75 = 13,333)
; This value is ideal as I found out. I tried 60 as most lcd monitors run at
; this rate. But the gui function needs too much runtime and is so slower
; then the simple sleep wait, which handles the firing.
RefreshRate := 13
; The time for the settimer used for the loop, which calls the repeated
; checking of the mouse button.
CheckLoopMS := 13
; #############################################################################
 
; here are internal variables declared and calculated
;
; get the width of the actual screen and half it to get the middle
xMidScrn         := A_ScreenWidth //2
; get the height of the actual screen and half it to get the middle
yMidScrn         := A_ScreenHeight //2
; calculate the position of the gui from the middle position
Gui1X           := xMidScrn - xMidScrn *.1
Gui1Y           := yMidScrn - yMidScrn *.15
Gui2X           := xMidScrn
Gui2Y           := yMidScrn
; if the system is in chargin mode
Charging         := 0
; charge status of the gauss rifle
GaussCharge  := 0
; recycle status of the gauss rifle
GaussRecycle := 0
; The switch to toggle the GUI on or off.
Toggle  := 0
; if the gauss is in it's recycling mode
Recycling := 0
; if the gauss is charging
Charging  := 0
; The loop delay for the GUIs. It is calculated from the Refresh Rate of
; the Monitor. The FPS variable has to set manual and cannot be gathered by
; AutoHotKey.
GuiLoopDelay := Round(1000 / RefreshRate, 0)
; Number of loop iteration for one charge cycle
ChargeLoopIteration := ChargeTime / GuiLoopDelay
; The value to add for a single loop run for the charge cycle of the GUI progress
ChargeAddLoopValue := 100 / ChargeLoopIteration
; Number of loop iteration for one recycle cycle
RecycleLoopIteration := RecycleTime / GuiLoopDelay
; The value to subtract for a single loop run for the recycle cycle of the GUI
; progress. The progress bar is set to 100% in the beginning.
RecycleSubLoopValue := 100 / RecycleLoopIteration
; Is set when the mouse button is pressed.
ButtonPressed := 0              
 
; Here is the GUI created
;
; This Removes the window (if it exists) and all its controls, freeing the
; corresponding memory and system resources. If the script later recreates
; the window, all of the window's properties such as color and font will
; start off at their defaults (as though the window never existed). If Gui
; Destroy is not used, all GUI windows are automatically destroyed when the
; script exits.
Gui, Destroy
; Makes the window stay on top of all other windows
Gui, +AlwaysOnTop
; Sets the background color of the window and/or its controls.
Gui, Color, Black
; Caption (present by default): Provides a title bar and a thick window
; border/edge. When removing the caption from a window that will use WinSet
; TransColor, remove it only after setting the TransColor.
Gui -Caption
; Provides a narrower title bar but the window will have no taskbar button.
Gui +ToolWindow
; Adds a control to a GUI window (first creating the GUI window itself, if
; necessary).
; Progress: A dual-color bar typically used to indicate how much progress has
; been made toward the completion of an operation.
Gui, Add, Progress, vProgressGaussCharge h8 w130 cFACC2E Background2E2E2E xp+20 yp+130
Gui, Add, Progress, vProgressGaussRecycle h8 w130 cRed Background2E2E2E yp-8
; the name for this GUI
Gui, Show, Y%Gui1y% X%Gui1X%, MWO_Gauss_Overlay, NoActivate, Title of Window
; make it transparent
WinSet, Transcolor, Black, ahk_class AutoHotkeyGUI
; show the values
GuiControl,, ProgressGaussCharge, %GaussCharge%
GuiControl,, ProgressGaussRecycle, %GaussRecycle%
; hide the GUI
Gui, Hide
Return
 
; When in Windows press Windows+Alt+G to toggle the script on and off.
;
; The characters #!G are the defined hotkey for this function. The # is the
; modifier for the windows key. The ! is the modifier for the control key.
; The G is for the character G on the keyboard.  
#!G::
  ;toggles up and down states.
  toggle:=!toggle
  if toggle
  {
        ; tell the gui to show
        Gui, Show
        ; Activates the specified window (makes it foremost). In this case is
        ; this MechWarrior Online.
        WinActivate MechWarrior Online
  }
  Else
  {
        ; tell the gui to hide  
        Gui, Hide
  }
return
 
; This would make the rest of the script only active when MechWarrior Online
; is running.
#IfWinActive MechWarrior Online
 
; When in MWO press Ctrl+Alt+G to toggle the script on and off
^!G::
  toggle:=!toggle ;toggles up and down states.
  if toggle
  {
        ; tell the gui to show
        Gui, Show
        ; Activates the specified window (makes it foremost). In this case is
        ; this MechWarrior Online.        
        WinActivate MechWarrior Online
  }
  Else
  {
        Gui, Hide
  }
return
 
; inbuild function when the right mouse button is pressed
Rbutton::
  ; sets the variable, that the mouse button is pressed
  ButtonPressed:= 1
  ; when the gauss is neither in charge nor in recycle mode and the macro is
  ; toggled on.
  if (Recycling = 0) and (Charging = 0) and toggle
  {
        ; Calls the subroutine for further handling of the mouse button event
        ; the value of -1 means, that this subroutine is called only a single time
        ; per mouse button press.
        Settimer, RightMouseButtonPressed, -1
  }
Return
 
; inbuild function when the right mouse button is released
Rbutton up::
  ; sets the variable, that the mouse button is released
  ButtonPressed := 0
Return
; This subroutine is called from the Rbutton event for the right mouse button.
RightMouseButtonPressed:
  ; Set the variable that the gauss is now charging.
  Charging := 1
  ; staring the looping settimer for this subroutine has to be switched off
  settimer, CheckMouseButton, %CheckLoopMS%
  ; The gCharge function will be called per settimer and the repeating time
  ; value is set with the calculated value for the set fps.
  Settimer, gCharge, %GuiLoopDelay%
  ; Call the function which handles the charging and firing of the gauss rifle.  
  FireWeapon(GaussWeaponGroup, ChargeTime)
  ; Set the variable that the gauss is now recycling.
  Recycling := 1
  ; set the recylce progress bar to 100%
  GaussRecycle := 100
  ; show the new value of the progress bar
  GuiControl,, ProgressGaussRecycle, %GaussRecycle%
  ; The gRecycle function will be called per settimer and the repeating time
  ; value is set with the calculated value for the set fps.
  Settimer, gRecycle, %GuiLoopDelay%
Return
 
; This subroutine is looped by a settimer, checking if the mouse button is
; pressed or released.
CheckMouseButton:
  ; when the button is released
  if ButtonPressed = 0
  {
        ; the looping settimer for this subroutine has to be switched off
        settimer, CheckMouseButton, off
  }
  ; the mouse button is still pressed
  else
  {
        ; and the gauss is neither in charge nor in recycle mode and the macro is
        ; toggled on.
        if (Recycling = 0) and (Charging = 0) and toggle
        {
          ; Calls the subroutine for further handling of the mouse button event
          ; the value of -1 means, that this subroutine is called only a single
          ; time per mouse button press.
          Settimer, RightMouseButtonPressed, -1
        }
  }
Return
 
; Charge and fire the gauss rifle
FireWeapon(Group, Time)
{
  ; Press down the key for the waepon group.
  Send {%Group% down}
 
  ; Keep it down for the charge time of the gauss rifle
  Sleep %Time%
 
  ; Release the key for the waepon group.
  Send {%Group% up}
 
  ; set the global variable, that the charge cycle is over
  ; global Charging := 0
 
  ; set the global variable, that the gauss is now recycling
  ; global Recycling := 1
}
 
; The loading of the gauss rilfe displayed as GUI progress bars  
gCharge:
  ; the progressbar should be filled when the progress status is under 100%
  if GaussCharge < 100
  {
        ; add the calculated value to the charge status
        GaussCharge := GaussCharge + ChargeAddLoopValue
 
        ; the value should not be bigger then 100
        if GaussCharge > 100
        {
          ; set it flat to 100
          GaussCharge := 100
        }
 
        ; show the new value
        GuiControl,, ProgressGaussCharge, %GaussCharge%
  }
 
  ; the progress bar is now completly filled and the status value equals 100
  if GaussCharge = 100
  {
        ; switch off the charge mode of the gauss rifle
        Charging := 0
        ; set the charge status to 0%
        GaussCharge := 0
  
        ; show the new charge status
        GuiControl,, ProgressGaussCharge, %GaussCharge%
  
        ; turn the timer for this function off
        settimer, gCharge, off  
  }
Return
 
; The recycling cyclus of the weapon
gRecycle:
  ; the progressbar will reduced if the value is above 0
  if GaussRecycle > 0
  {
        ; subtract the calculated value to the recycle status
        GaussRecycle := GaussRecycle - RecycleSubLoopValue
        ; the value should not be smaller then 0
        if GaussRecycle < 0
        {
          ; set it flat to 0
          GaussRecycle := 0
        }
        ; show the new recycle status
        GuiControl,, ProgressGaussRecycle, %GaussRecycle%
  }
  ; The progress bar for the gauss recycle is now back to 0
  if GaussRecycle = 0
  {
        ; switch off the recycling mode of the gauss rifle
        Recycling := 0
        ; turn the timer for this function off
        settimer, gRecycle, off
  }
Return
