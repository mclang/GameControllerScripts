﻿;
; Autohotkey script for using joystick as absolute aiming device, i.e a mouse.
; Mainly useful when playing games like Mechwarrior: Online where joystick is left as
; second class aiming device but joystick still gives that fuzzy warm _simulation_ feeling.
;
; !!! IMPORTANT !!!
;
; The X/Y ratios used here were calibrated with specific mouse/windows/game settings
; and screen resolution of 1920x1200. Calibrate `RANGE_CR` and `TWIST_CR` multipliers
; again if the screen size changes.
;
; MWO **INGAME** mouse settings:
; - Sensitivity:  0.3
; - Smooth:       0.0
; - Acceleration: 0.0
;
; WINDOWS mouse properties:
; - Acceleration, Precision, etc: off
; - Cursor/Pointer Speed: 50%
;
; Mouse (Logitech G502) with static __on-board__ profile mode:
; - Default DPI: 2000
; - Switch DPI:  1000
; - These SHOULDN'T matter though b/c they affect how the mouse REPORTS its movement, not how it moves
;
; INGAME Settings (27.03.2021)
; - Screen resolution: 2560x1440 fullscreen
; - Joystick:
;   * Remove Torso twist and turn b/c handled by this mouse AHK emulation
;   * Remove mouse left button from WG1 b/c handled by joystick trigger
; - Throttle:
;   * Analog throttle & turn
;   * Invert Throttle: ON
;   * Throttle range:  FULL
;   * Throttle decay:  OFF
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

; Mech torso twist range and speed configuration.
; - Configure both the MECH_TWIST_RANGES and MECH_TWIST_RATES according to the ingame yaw/pitch values.
; - Note value differences between running arms lockked versus arms free.
; - Set USE_DESKTOP_RANGES if you want to use DESKTOP values instead of ingame MECH values
; - Set SYNC_TWIST_RANGES if you want yaw/pitch ranges synched (you probably want this!)
USE_DESKTOP_RANGES := false
SYNC_TWIST_RANGES  := true


; TODO:
; - use __arm__ range and speed when arm lock is off
; - unlock arms and use __full__ up/down pitch range, but slower torso speed?

; Warhammer, arms locked, with the usual mobility skills:
;MECH_TWIST_RANGES := [116.6, 25]
;MECH_TWIST_RATES  := [93, 51]

; Warhammer 9D(S), __without__ any mobility nodes (arms free for ranges!)
;MECH_TWIST_RANGES := [110, (25+25)]
;MECH_TWIST_RATES  := [81, 51]

; Warhammer IIC, with some accel/deccel/torso nodes
;MECH_TWIST_RANGES := [(75+30), (20+30)]
;MECH_TWIST_RATES  := [169, 169]

; Madcat MK II: The usual torso twist nodes
;MECH_TWIST_RANGES := [88.4, 20]
;MECH_TWIST_RATES  := [69.6, 39]

; Huncback IIC-B with right side mobility speed tweak
;MECH_TWIST_RANGES := [115, 26]
;MECH_TWIST_RATES  := [81, 51]

; Enforcer 'Ghillie' with right side mobility full speed tweak
;MECH_TWIST_RANGES := [125, 20]
;MECH_TWIST_RATES  := [112, 68]

; Highlander Heavy metal - Baradul's LB10x, MRM40, 3xML, LFE325
;MECH_TWIST_RANGES := [90, 20]
;MECH_TWIST_RATES  := [90, 56]

; IS Marauder, __without__ any mobility nodes
;MECH_TWIST_RANGES := [85, (20+30)]
;MECH_TWIST_RATES  := [90, 56]

; KGC-001 S without mobility nodes, but arms free
;MECH_TWIST_RANGES := [100, (25+30)]
;MECH_TWIST_RATES  := [146, 146]

; Blood Asp BAS-A, Quad PPC setup
;MECH_TWIST_RANGES := [(80+20), (20+20)]
;MECH_TWIST_RATES  := [158, 158]

; Bushwacker High Roller, Dual RAC/5
MECH_TWIST_RANGES := [(110+35), (30+30)]
MECH_TWIST_RATES  := [236, 236]

; Cyclops 'Sleipnir'
;MECH_TWIST_RANGES := [(80+20), (20+30)]
;MECH_TWIST_RATES  := [225, 225]


; Multipliers needed to convert ingame mech values into the script mouse values
RANGE_CR := 44.9    ; Tested with above mouse settings that inside mechpit 1920 ~ 42° and 4000 ~ 89°
TWIST_CR := 0.28    ; Tested with above mouse settings that max twist speed limit for 304°/s is around ~85

if ( USE_DESKTOP_RANGES ) {
    MOUSE_UNITS_RANGE := [1920, 1200]   ; Using these with pointer speed of 50% happens to be just right for desktop use :O
    MAX_TWIST_RATES   := [999, 999]
} else {
    MOUSE_UNITS_RANGE := [MECH_TWIST_RANGES[1] * RANGE_CR, MECH_TWIST_RANGES[2] * RANGE_CR]
    MAX_TWIST_RATES   := [MECH_TWIST_RATES[1]  * TWIST_CR, MECH_TWIST_RATES[2]  * TWIST_CR]
}

if ( SYNC_TWIST_RANGES ) {
    MOUSE_UNITS_RANGE[2] := MOUSE_UNITS_RANGE[1]
}


STICK_ID    := 1                    ; The ID of the stick to take input from for mouse aim
THROTTLE_ID := 2                    ; The ID of the throttle

STICK_AXES   := ["X", "Y"]              ; The axes on the stick to take input from
STICK_PREFIX := STICK_ID "Joy"
STICK_TRIGGER_1 := STICK_PREFIX "1"
STICK_WRELEASE  := STICK_PREFIX "2"     ; Weapon Release
STICK_NSTEERING := STICK_PREFIX "3"     ; Nose Steering
STICK_PLEVER    := STICK_PREFIX "4"     ; Pinkie Lever
STICK_MMC       := STICK_PREFIX "5"     ; Master Mode Control
STICK_TRIGGER_2 := STICK_PREFIX "6"
THROTTLE_PREFIX := THROTTLE_ID "Joy"
THROTTLE_09     := THROTTLE_PREFIX "9"  ; Throttle base LEFTMOST switch
THROTTLE_SE     := THROTTLE_PREFIX "10" ; Throttle base LEFT on/off switch
THROTTLE_ST     := THROTTLE_PREFIX "11" ; Throttle base RIGHT on/off switch
THROTTLE_HOME   := THROTTLE_PREFIX "12" ; Throttle base RED button


Hotkey, %STICK_TRIGGER_1%,      MouseButtonLeft
Hotkey, %STICK_MMC%,            RecenterViewState   ; Same button MUST be 'center torso to legs' AND 'RShift' set as 'reset zoom'
Hotkey, %THROTTLE_PREFIX% 3,    CW_EnemySpotted     ; Check that key 'E' is set to show 'Command Wheel' (default)
Hotkey, %THROTTLE_PREFIX% 6,    ToggleZoomedState   ; Make SURE same buttons is 'toggle max zoom' inside the game
Hotkey, %THROTTLE_ST%,          ToggleDakka

;
; Internal variables that should NOT be changed unless you know what you are doing
;
MAX_JOYSTICK_RANGE    := 100
JOYSTICK_OFFSET       := MAX_JOYSTICK_RANGE / 2
JOYSTICK_MOUSE_RATIOS := [MOUSE_UNITS_RANGE[1] / MAX_JOYSTICK_RANGE, MOUSE_UNITS_RANGE[2] / MAX_JOYSTICK_RANGE]
AXIS_NAMES := [STICK_PREFIX STICK_AXES[1], STICK_PREFIX STICK_AXES[2]]

; Set true when 'toggle max zoom' button (check `ToggleZoomedState` above) is pressed
zoomedin    := false
zoom_origin := [0, 0]

; This multiplier is used to lower 'DPI' while in zoom mode.
zoom_dpi_factors := [(MOUSE_UNITS_RANGE[1] / RANGE_CR / 250), (MOUSE_UNITS_RANGE[2] / RANGE_CR / 250)]


; Keep track of the current position so that we can skip updating when position does not change
current_values := [0,0]
Loop {
    ; Reset the move amount
    delta_move := [0, 0]
    ; Work out how much we want to move in X and Y
    Loop 2 {
        ; Get axis position in 0-100 float range.
        axis_in := GetKeyState( AXIS_NAMES[A_Index] )
        ; Work out what mouse "coordinate" that stick position equates to
        desired_value := (axis_in - JOYSTICK_OFFSET) * JOYSTICK_MOUSE_RATIOS[A_Index]
        ; Use reduced movement range when zoomed in:
        if ( zoomedin ) {
            desired_value := zoom_origin[A_Index] + zoom_dpi_factors[A_Index] * (desired_value - zoom_origin[A_Index])
        }
        ; Mouse positions MUST be integer values, otherwise STRANGE things happen
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



; Either:
; - Emulate normal mouse left button with drag-and-drop support
; or
; - Click left mouse button continuously until released (WIP!)
; - Could maybe be done directly using `GetKeyState( THROTTLE_ST )`?
do_the_dakka := false
MouseButtonLeft:
    SetMouseDelay, -1               ; Makes movement smoother.
    MouseClick, left,,, 1, 0, D     ; Hold down the left mouse button.
    SetTimer, WaitForLeftButtonUp, 10
    return

WaitForLeftButtonUp:
    if ( GetKeyState( STICK_TRIGGER_1 ) )
        return                      ; The button is still, down, so keep waiting.
    SetTimer, WaitForLeftButtonUp, off
    SetMouseDelay, -1               ; Makes movement smoother.
    MouseClick, left,,, 1, 0, U     ; Release the mouse button.
    return


;AutofireWeaponGroup:
;    SetTimer, AutoFireWG, 850
;    SetTimer, WaitForStopAutoFire, 10
;    return
;AutoFireWG:
;    MouseClick, left
;    return
;WaitForStopAutoFire:
;    if (  GetKeyState( STICK_TRIGGER ) )
;        return
;    SetTimer, AutoFireWG, off
;    SetTimer, WaitForStopAutoFire, off
;    return


; Toggle whether 'MouseButtonLeft' does:
; - click and hold (i.e normal mouse)
; - click and click and click... until released (WIP!)
ToggleDakka:
    do_the_dakka := true
    ; MsgBox Dakka enabled
    SetTimer, WaitForStopDakka, 1000
    return
WaitForStopDakka:
    if (  GetKeyState( THROTTLE_ST ) )
        return
    do_the_dakka := false
    ; MsgBox Dakka disabled
    SetTimer, WaitForStopDakka, off
    return


; Toggle zoomed state, i.e reduce movement rate
; Make sure same buttons is 'toggle max zoom' inside the game
ToggleZoomedState:
    zoomedin := !zoomedin
    if (zoomedin) {
        zoom_origin[1] := current_values[1]
        zoom_origin[2] := current_values[2]
    }
    return

; Center cursor in desktop mode AND reset ingame zoomed state
; - Same button __MUST__ also be set as 'center torso to legs' inside the game so that joystick gets recentered!
; - Also 'Right Shift'  __MUST__ be set as ingame 'reset zoom' keybinding (keyboard section)
RecenterViewState:
    CoordMode, Mouse, Screen
    mousemove, (A_ScreenWidth / 2), (A_ScreenHeight / 2)
    Send {RShift down}{RShift up}
    zoomedin := false
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


; Open 'Command Wheel' and select 'Enemy Spotted'
; - Check that key 'E' is set to show 'Command Wheel' (default)
; - The position of the right command wheel entry is tested with 1920x1200 and 2560x1440 resolutions (fullscreen!)
; - Sleep needed so that command wheel menu has time to open before mouse moves
CW_EnemySpotted:
    CoordMode, Mouse, Screen
    SendInput {E down}
    Sleep, 200
    mousemove, (1.2 * A_ScreenWidth / 2), (0.9 * A_ScreenHeight / 2)
    SendInput {E up}
    return
