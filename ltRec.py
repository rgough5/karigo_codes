"""
Author: Rhys Gough (Karigo Lab)
Usage: Record video with audio from a rasberry pi with the camera module and Ultramic UM250K Microphone
On running the python script you will be asked for a filename and the length (in seconds) to record for.
Video/audio is automatically broken up into 60 minute recordings with about a second lost in between recordings.
This can be adjusted, but note that .wav files have a max size 2GB

NOTE: if you aren't recording ultrasonic audio, this might help, but there are better ways to record an .mp4 with audio

Requirements:
-Rasberry Pi (tested on Model 4B)
-RasPi camera module
-A USB microphone (tested w/ Ultramic UM250K Microphone)
-Some sort of cooling method for the RasPi

Issues:
-Adjusting settings is a pain because the author is lazy
-About a second lost between broken up recordings due to innefficient camera management
-Audio start is only roughly synced with the video, but this should be fine for most applications if they are processed separately
-
"""
from picamera2 import Picamera2
from multiprocessing import Process
from os import system
import datetime

def recA(fname, t):
    #audio literally just sends a command to use ALSA to record audio
    #capped at 2GB
    system("arecord --rate=250000 --duration=" + str(t) + " " + fname + ".wav")

def recV(fname, t):
    picam = Picamera2()
    #size is not window size, but image resolution
    #FrameDurationLimits controls the FPS, eg (100000,100000) is 10 fps
    #Exposure 5000-8000 seems good for the overhead red light in the 534 behavior rooms
    cam_config = picam.create_video_configuration({'size': (1280, 720)}, controls={'FrameDurationLimits': (100000, 100000), 'ExposureTime': 8000})
    # it is probably better to start and leave the encoder on between recordings
        # I should eventually add some flag to start/stop the encoder
    picam.start_and_record_video(fname+'.mp4', duration= t, config=cam_config)

if __name__ == '__main__':
    fname = input('To record, enter file prefix: ')
    t = int(input('recording length in seconds: '))
    i = 0
    #adjust the number t is divided by to control number and length of chunks (unit is seconds)
    #for whatever reason just assigning this number to a variable throws errors so be sure to adjust all 5 instances of it below
    while i < t//3600:
        i += 1
        pv = Process(target=recV, args=(fname+'_'+str(i)+'_'+'{:%m%d%y-%H%M%S}'.format(datetime.datetime.now()), 3600))
        pa = Process(target=recA, args=(fname+'_'+str(i)+'_'+'{:%m%d%y-%H%M%S}'.format(datetime.datetime.now()), 3600))

        pv.start()
        pa.start()

        pv.join()
        #pa.join() #commented out because audio process takes awhile to finish

    i += 1
    pv = Process(target=recV, args=(fname+'_'+str(i)+'_'+'{:%m%d%y-%H%M%S}'.format(datetime.datetime.now()), t%3600))
    pa = Process(target=recA, args=(fname+'_'+str(i)+'_'+'{:%m%d%y-%H%M%S}'.format(datetime.datetime.now()), t%3600))

    pv.start()
    pa.start()