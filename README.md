# bentoMATAug
Some scripts designed for the Karigo Lab to add/edit `.annot` files for the bento mouse behavior annotation software created by Ann Kennedy: https://github.com/neuroethology/bentoMAT/blob/master/LICENSE.txt.

## Usage
### Annotate a directory
call2annot.m and led2annot.m work best one at a time on existing annotations, but if you want to add annotate several files at onces throw all the files into the same directory and run annotDir.m on that directory.
### Annotate a directory
I recommend just using but you can use `annotDir.m`. This currently assumes that your directory is setup with a certain ratio:
1 video : 1 usv call file : 1 desired annotation OR 2 videos : 1 usv call file : 1 desired annotation

### Annotate a single file.
Both `call2annot.m` and `led2annot.m` can be used on individual files to add their respective annotations to existing `.annot` files. Both function similairly by taking 3 arguments. Argument 1 = the DeepSqueak call file or LED mp4 file, argument 2 = the file to copy and add an annotation to, argument 3 = the name of the file to save as, inputing the same argument 3 as 2 will result in overwriting the original annotation file. An example would be `call2annot('call.mat', 'mouse1.annot', 'mouse1calls.annot')`.

This is a work in progress. If you have any issues or requests please message me over Slack

### Convert annotations to csv.
An awful WIP, I probably should have left this in the dev branch, but hey it's my repo. Use annot2csv.ipynb to convert a an annotation file to a csv with a text file key. This csv will have one columns per channel and rows equal to the desired number of timestamps. This assumes annotations within a channel do not overlap. It can easily be editted to ignore channels and simply have one behavior per column, but that increases the file size and is a lot slower.
