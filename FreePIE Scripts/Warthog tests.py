#
# Select joystic by pressing first button (usually trigger) after script is started
def find_joystic_id():
	for id in range(0, len(joystick)): 
		if joystick[id].getPressed(0):
			axis_max = vJoy[id].axisMax
			joystick[id].setRange(-1 * axis_max, axis_max)
			return id
	return None
	

# X value and Y value define limits of torso travel,
# different sticks/screen/mech combinations will vary - AND 'setRange' changes things completely!
if starting:
	joy_id = None
	enabled = False
	type = "n/a"

if enabled:
	mouse.deltaX = filters.delta(joystick[0].x) / 0.75 # *gain, lower numbers = higher gain LEFT/RIGHT
	mouse.deltaY = filters.delta(joystick[0].y) / 1.15 # *gain, lower numbers = higher gain UP/DOWN
	diagnostics.watch(mouse.deltaX)
	diagnostics.watch(mouse.deltaY)
  
toggle = keyboard.getPressed(Key.LeftBracket)
 
if toggle:
	enabled = not enabled

if joy_id == None:
	joy_id = find_joystic_id()

diagnostics.watch(joy_id)

#mouse_stopped = filters.stopWatch(mouse.deltaX == 0 and mouse.deltaX == 0, 500)
#diagnostics.watch(mouse_stopped)

diagnostics.watch( vJoy[0].axisMax ) # gives 16382

warthog_x = joystick[0].x
warthog_y = joystick[0].y

# Warthog range seems to be -1000 (left/up) to 1000 (right/down)
diagnostics.watch(warthog_x)
diagnostics.watch(warthog_y)

var_deadzone = 100
dzX = filters.deadband(warthog_x, var_deadzone)
dzY = filters.deadband(warthog_y, var_deadzone)
diagnostics.watch(dzX)
diagnostics.watch(dzY)

# Makes SINGLE keypress only
keyboard.setKey(Key.W, warthog_y < -500)
keyboard.setKey(Key.S, warthog_y >  500)

# Center mech torso to the legs so that possible missaligment is fixed automaticaly
centering_limit = 0.001 * joy_range
joy_is_centered = (warthog_x > -centering_limit and warthog_x < centering_limit and warthog_y > -centering_limit and warthog_y < centering_limit)
keyboard.setKey(Key.C, joy_is_centered)
diagnostics.watch(centering_limit)
diagnostics.watch(joy_is_centered)



# if warthog_y < -500:
# 	keyboard.setPressed(Key.W)
# elif warthog_y > 500:
# 	keyboard.setPressed(Key.S)

if keyboard.getKeyDown(Key.H) and keyboard.getKeyDown(Key.B) and keyboard.getKeyDown(Key.K):
 	type = "Hunckback"
elif keyboard.getKeyDown(Key.LeftControl) and keyboard.getPressed(Key.C):
 	type = "n/a"
diagnostics.watch(type)

#
# https://gist.github.com/NanoPi/930b08ccb8c4f5ee7c3b
# https://steamcommunity.com/sharedfiles/filedetails/?id=269643170
#
