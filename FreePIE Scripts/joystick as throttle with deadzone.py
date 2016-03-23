#
# Script to use left-hand joystick as analog throttle with large deadzone in the
# middle, so that steering mech left or right does not affect the throttle level.
#
# Uses 'vJoy[id].axisMax' to set the joystick range
#

#
# https://gist.github.com/NanoPi/930b08ccb8c4f5ee7c3b
# https://steamcommunity.com/sharedfiles/filedetails/?id=269643170
#


# Select joystic by pressing first button, which is usually trigger
def find_joystic_id():
	global joy_id, joy_range
	button_to_wait = 0
	for id in range(0, len(joystick)):
		if joystick[id].getPressed(button_to_wait):
			joy_id = id
			joy_range = vJoy[0].axisMax
			joystick[id].setRange(-joy_range, joy_range)


if starting:
	enabled = False
	joy_id  = 0
	joy_range = 1000

if enabled:
	diagnostics.watch(joy_id)
	diagnostics.watch( vJoy[0].axisMax ) # gives 16382 for Warthog
	diagnostics.watch(warthog_x)
	diagnostics.watch(warthog_y)
	diagnostics.watch(dzX)
	diagnostics.watch(dzY)
	diagnostics.watch(axis_deadzone)
	diagnostics.watch(throttle_limit)


toggle = keyboard.getPressed(Key.RightBracket)

if toggle:
	enabled = not enabled

if joy_id == 0:
	find_joystic_id()


warthog_x = joystick[joy_id].x
warthog_y = joystick[joy_id].y

axis_deadzone = 0.25 * joy_range
dzX = filters.deadband(warthog_x, axis_deadzone)
dzY = filters.deadband(warthog_y, axis_deadzone)

throttle_limit = 0.50 * joy_range

# Makes only SINGLE keypress
#keyboard.setKey(Key.W, warthog_y < -throttle_limit)
#keyboard.setKey(Key.S, warthog_y >  throttle_limit)

# Creates keypresses as fast as FreePIE runs, which is TOO fast to control throttle
if warthog_y < -throttle_limit:
	keyboard.setPressed(Key.W)
elif warthog_y >  throttle_limit:
	keyboard.setPressed(Key.S)
