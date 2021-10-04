# Mechwarrior 5: Mercenaries - Joystick/Throttle Configuration

Some joysticks and throttles are supported by MW5 out of the box. List of thewse can be found from
official [Peripheral Resources](https://mw5mercs.com/resources/2020/01/31-peripheral-resources) page.
Other joysticks and throttles need usually custom configuration, which can be done by creating or
editing `HOTASMappings.Remap` file. This file can be found in two places, depending on the OS.

**Windows:**
```
C:\Users\<user>\AppData\Local\MW5Mercs\Saved\SavedHOTAS\HOTASMappings.Remap
```
**Linux (Steam with default game library path):**
```
$HOME/.local/share/Steam/steamapps/compatdata/784080/pfx/drive_c/users/steamuser/AppData/Local/MW5Mercs/Saved/SavedHOTAS/HOTASMappings.Remap
```

More information can be found from official documentation and community collected configurations file:
- https://static.mw5mercs.com/docs/MW5HotasRemappingDocumentation.pdf
- https://docs.google.com/document/d/1jjTBBtES-wnbChVzDqH7nUZGiOa8ZT0WD3fSVxAA5G8/edit#heading=h.8ja3d05vb653

Note that on the linux side, best way to test your device and find e.g axis names, is either using `jstest-gtk`
or wonderfull [Gamepad Tester](https://gamepad-tester.com/) web page.

Furthermore, in order to keep `HOTASMappings.Remap` file under version control without the need to copy it around
after every change, it should be either hard or symbolic linked into the right location under the game app data
directory. For example hard link:
```
$ cp -al HOTASMappings.Remap "$HOME/.local/<path to MW5>/Saved/SavedHOTAS/HOTASMappings.Remap
```

