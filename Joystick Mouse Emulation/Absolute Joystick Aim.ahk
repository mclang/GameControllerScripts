;
; Autohotkey script for using joystick as absolute aiming device, i.e a mouse.
; Mainly useful when playing games like Mechwarrior: Online where joystick is left as
; second class aiming device but joystick gives that fuzzy warm simulation feeling.
;
; IMPORTANT!
; The X/Y ratios used here are calibrated with following INGAME mouse settings:
; - Sensitivity:  0.3
; - Smooth:       0.0
; - Acceleration: 0.0
; Also Windows Mouse Properties affect the calibrated ranges:
; - Acceleration, Precision, etc: off
; - Pointer Speed: 40%
;
; Useful Links:
; - https://autohotkey.com/docs/scripts/JoystickTest.htm
; - https://autohotkey.com/docs/KeyList.htm
; - http://mwomercs.com/forums/topic/225233-absolutejoy-proof-of-concept-for-absolute-joystick-aim-in-mwo/
;
#NoEnv                  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force

; Add mouse button emulation:
; #include Mouse Button Mapping.ahk

;
; Configure following according to the joystick and required ingame movement range.
; NOTE: With all [arrays], the first value is X (yaw) and the second is Y (pitch).
;
RANGE_CR := 44.9    ; Tested with above mouse settings that inside mechpit 2600 ~ 58° and 4000 ~ 89°
TWIST_CR := 3.53    ; Tested with above mouse settings that max twist speed limit for 167°/s is around 45~50

; The total range of movement, in mouse units. (2600 = ~1920px when in windows desktop)
;                       yaw  pitch
;MOUSE_UNITS_RANGE := [2600, 1650]
;MAX_TWIST_RATE    := 999

; TODO:
; - use arm range and speed when arms lock is off

; Warhammer, arms locked, without skill nodes
;MOUSE_UNITS_RANGE := [110*RANGE_CR, 25*RANGE_CR]
;MAX_TWIST_RATES   := [81/TWIST_CR, 51/TWIST_CR]
; Warhammer, arms locked, with the usual mobility skills:
;MOUSE_UNITS_RANGE := [116.6*RANGE_CR, 25*RANGE_CR]
;MAX_TWIST_RATES   := [89.5/TWIST_CR, 51/TWIST_CR]

; Madcat MK II: no mobility skills
;MOUSE_UNITS_RANGE := [85*RANGE_CR, 20*RANGE_CR]
;MAX_TWIST_RATES   := [63/TWIST_CR, 39/TWIST_CR]
; Madcat MK II: The usual torso twist nodes
;MOUSE_UNITS_RANGE := [88.4*RANGE_CR, 20*RANGE_CR]
;MAX_TWIST_RATES   := [69.6/TWIST_CR, 39/TWIST_CR]

; Huncback IIC: The usual torso twist nodes TOO QUICK I THINK?
MOUSE_UNITS_RANGE := [120*RANGE_CR, 26*RANGE_CR]
MAX_TWIST_RATES   := [94/TWIST_CR, 51/TWIST_CR]


; Set this __if__ you want Y and X axes to have the same __range__:
MOUSE_UNITS_RANGE[2] := MOUSE_UNITS_RANGE[1]

STICK_ID   := 1                     ; The ID of the stick to take input from for mouse aim
STICK_AXES := ["X", "Y"]            ; The axes on the stick to take input from

;
; Internal variables that should not be changed unless you know what you are doing
;
MAX_JOYSTICK_RANGE    := 100
JOYSTICK_OFFSET       := MAX_JOYSTICK_RANGE / 2
JOYSTICK_MOUSE_RATIOS := [MOUSE_UNITS_RANGE[1] / MAX_JOYSTICK_RANGE, MOUSE_UNITS_RANGE[2] / MAX_JOYSTICK_RANGE]
AXIS_NAMES := [STICK_ID "Joy" STICK_AXES[1], STICK_ID "Joy" STICK_AXES[2]]

; Set true when 'toggle zoom' button (2Joy9) is pressed
zoomedin    := false
zoom_origin := [0, 0]

; This multiplier is used to lower 'DPI' while in zoom mode. For Highlander's range of 125°, a value of 0.5 was okay.
zoom_dpi_factors := [MOUSE_UNITS_RANGE[1] / RANGE_CR / 250, MOUSE_UNITS_RANGE[2] / RANGE_CR / 250]

; Set true when 'reduce DPI' button is hold down
reduce_dpi  := false
rdpi_origin := [0, 0]


; Start timer to monitor if 'tag' should be enabled using firing group 6
;SetTimer, MonitorFireGroup6, 1000


current_values := [0,0]
Loop {
    ; Reset the move amount
    delta_move := [0, 0]
    ; Work out how much we want to move in X and Y
    Loop 2 {
        ; Get axis position in 0-100 float range.
        axis_in := GetKeyState(AXIS_NAMES[A_Index])
        ; Work out what mouse "coordinate" that stick position equates to
        desired_value := (axis_in - JOYSTICK_OFFSET) * JOYSTICK_MOUSE_RATIOS[A_Index]
        ; Use reduced movement range when zoomed in
        ;if ( zoomedin ) {
        ;    desired_value := zoom_origin[A_Index] + zoom_dpi_factors[A_Index] * (desired_value - zoom_origin[A_Index])
        ;}
        ;if ( reduce_dpi ) {
        ;    desired_value := rdpi_origin[A_Index] + 0.5 * (desired_value - rdpi_origin[A_Index])
        ;}
        ; Mouse positions MUST be integer values, otherwise strange things happen
        desired_value := round( desired_value )
        ; Do we need to generate mouse input?
        if (desired_value != current_values[A_Index]) {
            ; Find out how much we want to move the mouse by
            delta_move[A_Index] := desired_value - current_values[A_Index]
            ; Limit the amount of movement for this tick to the MAX_TWIST_RATE
            delta_move[A_Index] := abs(delta_move[A_Index]) > MAX_TWIST_RATES[A_Index] ? MAX_TWIST_RATES[A_Index] * sgn(delta_move[A_Index]) : delta_move[A_Index]
            ; Update current value
            current_values[A_Index] += delta_move[A_Index]
        }
    }
    ; Generate mouse input for both axes at once
    DllCall("mouse_event", "UInt", 0x0001, "Int", delta_move[1], "Int", delta_move[2], "UInt", 0, "UPtr", 0)
    Sleep 10
}

; Returns -1 if value is negative, or +1 if 0 or positive
sgn(val) {
    if (val >= 0)
        return 1
    else
        return -1
}



; Emulate mouse left button with joystick trigger
1Joy1::
    SetMouseDelay, -1            ; Makes movement smoother.
    MouseClick, left,,, 1, 0, D  ; Hold down the left mouse button.
    SetTimer, WaitForLeftButtonUp, 10
    return

WaitForLeftButtonUp:
    if ( !GetKeyState( "1Joy1" ) ) {
        SetTimer, WaitForLeftButtonUp, off
        SetMouseDelay, -1  ; Makes movement smoother.
        MouseClick, left,,, 1, 0, U  ; Release the mouse button.
    }
    return


; Use 'pinkie lever' to center cursor
; - Works ONLY on desktop and inside mech bay, NOT while in game!
; - In game, joy0btn3 is 'toggle arm lock'
1Joy4::
    CoordMode, Mouse, Screen
    mousemove, (A_ScreenWidth / 2), (A_ScreenHeight / 2)
    return

; Use 'second' trigger, i.e button 6, to autofire weapon group 6 at specific interval
; NOTE: Using 'SendInput' didn't work!
;1Joy6::
;    Send {6 down}{6 up}
;    SetTimer, AutoFireWP6, 850
;    SetTimer, WaitForStopAutoFire, 10
;    return
;AutoFireWP6:
;    Send {6 down}{6 up}
;    return
;WaitForStopAutoFire:
;    if ( !GetKeyState( "1Joy6" ) ) {
;        SetTimer, AutoFireWP6, off
;        SetTimer, WaitForStopAutoFire, off
;    }
;    return

; Toggle zoomed state, i.e reduce movement rate, with Throttle R2/9 button.
; - Same button __MUST__ also be set as 'toggle max zoom' inside the game!
2Joy9::
    zoomedin := !zoomedin
    if (zoomedin) {
        zoom_origin[1] := current_values[1]
        zoom_origin[2] := current_values[2]
    }
    return

; Reset zoomed state with Warthog button 5, Master Mode Control.
; - Same button __MUST__ also be set as 'center torso to legs' inside the game so that joystick gets recentered!
; - Check that key '0' is set as 'reset zoom'
1Joy5::
    zoomedin := false
    Send {0 down}{0 up}
    return


; Reduce movement range while button is pressed
; If button is changed, remember to modify 'WaitForReduceRangeButton' also!
;2Joy9::
;    reduce_dpi     := true
;    rdpi_origin[1] := current_values[1]
;    rdpi_origin[2] := current_values[2]
;    SetTimer, WaitForReduceRangeButton, 10
;    return

;WaitForReduceRangeButton:
;    if ( !GetKeyState( "2Joy9" ) ) {
;        SetTimer, WaitForReduceRangeButton, off
;        reduce_dpi := false
;    }
;    return
