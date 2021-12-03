# Mechwarrior 5: Mercenaries - Joystick/Throttle Configuration

Some joysticks and throttles are supported by MW5 out of the box. List of these can be found from
official [Peripheral Resources](https://mw5mercs.com/resources/2020/01/31-peripheral-resources) page.
Other joysticks and throttles usually need custom configuration, which can be done by creating or
editing `HOTASMappings.Remap` file. The location of this file is under MW5 _Application Data_
directory that can be found in two places, depending on the OS.

**Windows:**
```
C:\Users\<user>\AppData\Local\MW5Mercs\Saved\SavedHOTAS\HOTASMappings.Remap
```
**Linux (Steam with default game library path):**
```
$HOME/.local/share/Steam/steamapps/compatdata/784080/pfx/drive_c/users/steamuser/AppData/Local/MW5Mercs/Saved/SavedHOTAS/HOTASMappings.Remap
```
**Note** though that the Steam **game** files and things like mods reside in different place, e.g:
```
$HOME/.local/share/Steam/steamapps/common/MechWarrior 5 Mercenaries/MW5Mercs
```

More information can be found from official documentation and community collected configurations file:
- https://static.mw5mercs.com/docs/MW5HotasRemappingDocumentation.pdf
- https://docs.google.com/document/d/1jjTBBtES-wnbChVzDqH7nUZGiOa8ZT0WD3fSVxAA5G8/edit#heading=h.8ja3d05vb653

Note that on the linux side, best way to test your device and find e.g axis names, is either using `jstest-gtk`
or wonderfull [Gamepad Tester](https://gamepad-tester.com/) web page. Calibrating should **not** be done with
any of the `jscal` or `jstest-gtk` tools though, because it shomehow makes **all the axes** go nuts in MW5.
In case of these kind of strange problems, check if `/var/lib/joystick/joystick.state` exists and delete it.
Afterwards reboot might be needed if no other clear/reset command is found.

Furthermore, in order to keep `HOTASMappings.Remap` file under version control without the need to copy it around
after every change, it should be either hard or symbolic linked into the right location under the game app data
directory. For example hard link:
```
$ cp -al HOTASMappings.Remap "$HOME/.local/<path to MW5>/Saved/SavedHOTAS/HOTASMappings.Remap
```

