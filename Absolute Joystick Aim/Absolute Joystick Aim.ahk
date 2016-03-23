; https://autohotkey.com/docs/misc/RemapJoystick.htm
; https://autohotkey.com/docs/scripts/JoystickTest.htm
; https://autohotkey.com/docs/KeyList.htm
; https://autohotkey.com/docs/scripts/JoystickMouse.htm
#SingleInstance force
; Configure these
INPUT_AXISX := "1JoyX"   ; Joystick axis to turn left/right
INPUT_AXISY := "1JoyY"   ; Joystick axis to loop up/down
MAX_WIDTH  := 2600       ; Mouse units of twist range. Varies with mech (2600 = ~1920px in windows, ~57° inside mechpit)
MAX_WIDTH  := 5300       ; 102° + 20° , Highlander 733p, Basic skills

MAX_HEIGHT := 1650       ; Mouse units of twist range. Varies with mech (1650 = ~1200px in windows)
MAX_HEIGHT := 2600       ; 57°

; non-configurables
CONV_RATIO_X := MAX_WIDTH / 101
CONV_RATIO_Y := MAX_HEIGHT / 101

curr_input_x  := 0
curr_input_y  := 0
curr_output_x := 0
curr_output_y := 0
centered      := false

Loop {
    x := GetKeyState(INPUT_AXISX)
    y := GetKeyState(INPUT_AXISY)

    ; Center torso to legs using 'c' key if joystick is centered

    x := x - 50.0   ; Shift scale to zero-centered
    y := y - 50.0
    if ( x != curr_input_x  ||  y != curr_input_y ) {
        output_x := round(x * CONV_RATIO_X)
        output_y := round(y * CONV_RATIO_Y)
        delta_x  := output_x - curr_output_x
        delta_y  := output_y - curr_output_y
        dllCall("mouse_event","Int",0x0001,"Int",delta_x,"Int",delta_y,"Int",0,"UPtr",0)
        curr_input_x  := x
        curr_output_x := output_x
        curr_input_y  := y
        curr_output_y := output_y
    }
    Sleep 10
}


; Works ONLY on desktop and in mech bay, NOT inside game!
1Joy5::
    CoordMode, Mouse, Screen
    x := (1920 / 2)
    y := (1200 / 2)
    mousemove, x, y
    return

; Use joystick trigger as mouse left button
1Joy1::
    SendInput {Click}
    return

; Emulate mouse wheel
1Joy7::
    SendInput {WheelUp}
    return
1Joy9::
    SendInput {WheelDown}
    return
