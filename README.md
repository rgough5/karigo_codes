# Codes for the Karigo Lab
Some scripts designed for the Karigo Lab. Mostly to work with `.annot` files for [bento](https://github.com/neuroethology/bentoMAT/tree/master)

## Stuff here
### Annotate a directory (not recommended)
I recommend just using but you can use `annotDir.m`. This currently assumes that your directory is setup with a certain ratio:
1 video : 1 usv call file : 1 desired annotation OR 2 videos : 1 usv call file : 1 desired annotation

### Annotate a single file.
Both `call2annot.m` and `led2annot.m` can be used on individual files to add their respective annotations to existing `.annot` files. Both function similairly by taking 3 arguments. Argument 1 = the DeepSqueak call file or LED mp4 file, argument 2 = the file to copy and add an annotation to, argument 3 = the name of the file to save as, inputing the same argument 3 as 2 will result in overwriting the original annotation file. An example would be `call2annot('call.mat', 'mouse1.annot', 'mouse1calls.annot')`.

This is a work in progress. If you have any issues or requests please message me over Slack

### Convert annotations to csv.
An awful WIP, I probably should have left this in the dev branch, but hey it's my repo. Use annot2csv.ipynb to convert a an annotation file to a csv with a text file key. This csv will have one columns per channel and rows equal to the desired number of timestamps. This assumes annotations within a channel do not overlap. It can easily be editted to ignore channels and simply have one behavior per column, but that increases the file size and is a lot slower.

### Arduino code for optogenetic stimulation
Hardware requirements: Arduino UNO, ThorLabs shutter that responds to external input as the 2hb025t does, wires, BNC Cables (optional)
Software requirements: Arduino IDE, serial monitor or a similair tool to read serial output from the Arduino
Turn the rotary encoder (the knob) on the Arduino to select shutter settings: serial monitor will display which option is selected. Press the indendent button the begin stimulation. Press down on the rotary encoder to stop stimulation early. (Further details and wiring guide coming).
