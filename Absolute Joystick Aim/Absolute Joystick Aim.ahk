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
;
#NoEnv                   ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force

; Add mouse button emulation:
; #include Mouse Button Mapping.ahk


; Configure these according to the joystick and required ingame movement range.
; With all [arrays], the first value is X (yaw) and the second is Y (pitch).
RANGE_CR          := 44.8           ; Tested with above mouse settings that inside mechpit 2600 ~ 58° and 4000 ~ 89°
MOUSE_UNITS_RANGE := [2600, 1650]   ; The total range of movement, in mouse units. (2600 = ~1920px in windows)
MOUSE_UNITS_RANGE := [RANGE_CR * 122, RANGE_CR * 122]   ; HGN-733p with perks and BASIC Twist X skill: 102° + 20°
MAX_TWIST_RATE := 47                ; The max twist rate, in mouse units (167°/s -> 45~50 -> ~3.55)
STICK_ID := 1                       ; The ID of the stick to take input from
STICK_AXES := ["X", "Y"]            ; The axes on the stick to take input from


; Internal variables that should not be changed unless you know what you are doing
MAX_JOYSTICK_RANGE := 100
JOYSTICK_OFFSET := MAX_JOYSTICK_RANGE / 2
JOYSTICK_MOUSE_RATIOS := [MOUSE_UNITS_RANGE[1] / MAX_JOYSTICK_RANGE, MOUSE_UNITS_RANGE[2] / MAX_JOYSTICK_RANGE]
AXIS_NAMES := [STICK_ID "Joy" STICK_AXES[1], STICK_ID "Joy" STICK_AXES[2]]


current_values := [0,0]
Loop {
    ; Reset the move amount
    delta_move := [0, 0]
    ; Work out how much we want to move in X and Y
    Loop 2 {
        ; Get state of axis
        axis_in := GetKeyState(AXIS_NAMES[A_Index])
        ; Work out at what mouse "coordinate" that the stick position equates to
        desired_value := round((axis_in - JOYSTICK_OFFSET) * JOYSTICK_MOUSE_RATIOS[A_Index])
        ; Do we need to generate mouse input?
        if (desired_value != current_values[A_Index]){
            ; Find out how much we want to move the mouse by
            delta_move[A_Index] := desired_value - current_values[A_Index]
            ; Limit the amount of movement for this tick to the MAX_TWIST_RATE
            delta_move[A_Index] := abs(delta_move[A_Index]) > MAX_TWIST_RATE ? MAX_TWIST_RATE * sgn(delta_move[A_Index]) : delta_move[A_Index]
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

; Works ONLY on desktop and in mech bay, NOT inside game!
1Joy5::
    CoordMode, Mouse, Screen
    mousemove, (A_ScreenWidth / 2), (A_ScreenHeight / 2)
    return
