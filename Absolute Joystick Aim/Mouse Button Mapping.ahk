;
; AutoHotkey script that makes joystick buttons to emulate mouse buttons and wheel
;
; https://autohotkey.com/docs/misc/RemapJoystick.htm
; https://autohotkey.com/docs/scripts/JoystickMouse.htm
; https://autohotkey.com/docs/KeyList.htm
;

; Set here which joystick button matches which mouse button or wheel direction:
ButtonLeft     = 1
ButtonRight    = 2
ButtonMiddle   = 3
ButtonForward  = 4
ButtonBackward = 5
; WheelDown  = 7
; WheelUp    = 9
WheelLeft  = 8
WheelRight = 10

; Controls how fast mouse wheel is scrolled when using POV. Decrease to turn faster.
WheelDelay = 250

; Select joystick to use
JoystickNumber = 1

; END OF CONFIG SECTION


#NoEnv
#SingleInstance force

JoystickPrefix = %JoystickNumber%Joy
Hotkey, %JoystickPrefix%%ButtonLeft%, ButtonLeft
Hotkey, %JoystickPrefix%%ButtonRight%, ButtonRight
Hotkey, %JoystickPrefix%%ButtonMiddle%, ButtonMiddle
; Hotkey, %JoystickPrefix%%ButtonForward%, ButtonForward
; Hotkey, %JoystickPrefix%%ButtonBackward%, ButtonBackward


; Check if joystick has POV control and use it as mouse wheel if found
GetKeyState, JoyInfo, %JoystickNumber%JoyInfo
IfInString, JoyInfo, P
    SetTimer, MouseWheel, %WheelDelay%

; END OF AUTOEXECUTE SECTION
;return



; The subroutines below do not use KeyWait because that would sometimes trap the
; WatchJoystick quasi-thread beneath the wait-for-button-up thread, which would
; effectively prevent mouse-dragging with the joystick.
ButtonLeft:
SetMouseDelay, -1            ; Makes movement smoother.
MouseClick, left,,, 1, 0, D  ; Hold down the left mouse button.
SetTimer, WaitForLeftButtonUp, 10
return

ButtonRight:
SetMouseDelay, -1             ; Makes movement smoother.
MouseClick, right,,, 1, 0, D  ; Hold down the right mouse button.
SetTimer, WaitForRightButtonUp, 10
return

ButtonMiddle:
SetMouseDelay, -1              ; Makes movement smoother.
MouseClick, middle,,, 1, 0, D  ; Hold down the right mouse button.
SetTimer, WaitForMiddleButtonUp, 10
return

WaitForLeftButtonUp:
if GetKeyState(JoystickPrefix . ButtonLeft)
    return  ; The button is still, down, so keep waiting.
; Otherwise, the button has been released.
SetTimer, WaitForLeftButtonUp, off
SetMouseDelay, -1  ; Makes movement smoother.
MouseClick, left,,, 1, 0, U  ; Release the mouse button.
return

WaitForRightButtonUp:
if GetKeyState(JoystickPrefix . ButtonRight)
    return  ; The button is still, down, so keep waiting.
; Otherwise, the button has been released.
SetTimer, WaitForRightButtonUp, off
MouseClick, right,,, 1, 0, U  ; Release the mouse button.
return

WaitForMiddleButtonUp:
if GetKeyState(JoystickPrefix . ButtonMiddle)
    return  ; The button is still, down, so keep waiting.
; Otherwise, the button has been released.
SetTimer, WaitForMiddleButtonUp, off
MouseClick, middle,,, 1, 0, U  ; Release the mouse button.
return


; Works ONLY on desktop and in mech bay, NOT inside game!
;1Joy5::
;    CoordMode, Mouse, Screen
;    mousemove, (A_ScreenWidth / 2), (A_ScreenHeight / 2)
;    return
; Use joystick trigger as mouse left button
;1Joy1::
;    SendInput {Click}
;    return
; Emulate mouse wheel
;1Joy7::
;    SendInput {WheelUp}
;    return
;1Joy9::
;    SendInput {WheelDown}
;    return


MouseWheel:
GetKeyState, JoyPOV, %JoystickNumber%JoyPOV
if JoyPOV = -1
    return
if (JoyPOV > 31500 or JoyPOV < 4500)
    SendInput {WheelUp}
else if JoyPOV between 13500 and 22500
    SendInput {WheelDown}
return
