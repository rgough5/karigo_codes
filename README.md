# Codes for the Karigo Lab
Some scripts designed for the Karigo Lab. Mostly to work with `.annot` files for [bento](https://github.com/neuroethology/bentoMAT/tree/master)

## Stuff here

### `ttl2_rot1.ino` - Arduino code for optogenetic stimulation
Upload `ttl2_rot1.ino` to the Arduino for control of a laser or shutter. This is intended for controling the on/off state of optogenetic stimulation.
Hardware requirements: Arduino UNO, ThorLabs shutter that responds to external input as the 2hb025t does, wires, BNC Cables (kinda oprtional)
Software requirements: Arduino IDE, serial monitor or a similair tool to read serial output from the Arduino
Turn the rotary encoder (the knob) on the Arduino to select shutter settings: serial monitor will display which option is selected. Press the indendent button the begin stimulation. Press down on the rotary encoder to stop stimulation early.
TODO: add wiring guide

### `call2annot.m` and `led2annot.m` - Annotate a single file.
Both `call2annot.m` and `led2annot.m` can be used on individual files to add their respective annotations to existing `.annot` files. Both function take 3 arguments. 1) the DeepSqueak call file or LED mp4 file, 2) the file to copy and add an annotation to, 3) the name of the file to save as, inputing the same argument 3 as 2 will result in overwriting the original annotation file. Example call: `call2annot('call.mat', 'mouse1.annot', 'mouse1calls.annot')`.

This is a work in progress. led2annot in particular is very slow. If you have any issues or requests please message me over Slack

### `annotDir.m` - Annotate a directory (not recommended)
I recommend just using the above but you can use `annotDir.m`. This currently assumes that your directory is setup with a certain ratio:
1 video : 1 usv call file : 1 desired annotation OR 2 videos : 1 usv call file : 1 desired annotation

### `annot2tables.m` - .annot conversion to logical tables
This converts .annot files to a structure with 1 + number of channel fields. The first field will always be frame data, the remaining fields will be tables for each annotation channel. These tables have a column for each behavior and a row for each frame. If a behavior is active during that frame, that element of the table is 1 other wise it is 0.

### NON-FUNCTIONAL: `annot2csv.ipynb`. - Simlair to `annot2tables.m`, but in python.
A work in progress and not really functional. It will be a .py file instead of a notebook when it's finished.
