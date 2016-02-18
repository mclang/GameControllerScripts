#
# Emulate mouse with any joystick. Original idea from MWO forum:
# http://mwomercs.com/forums/topic/62571-all-joystick-users/page__view__findpost__p__4840937
#
# NOTES:
# - X and Y values define limits of torso travel
# - Different sticks/screen/mech combinations will need different gain value
# - Setting joystick axis range using 'setRange' e.g to ±16000 for Warthog changes things completely!
# - In certain cases you may need to change the joystick number
#
if starting:
	enabled = False

if enabled:
	mouse.deltaX = filters.delta(joystick[0].x) / 1.4   # *gain, lower numbers = higher gain
	mouse.deltaY = filters.delta(joystick[0].y) / 2.8   # *gain, lower numbers = higher gain

toggle = keyboard.getPressed(Key.LeftBracket)

if toggle:
	enabled = not enabled
