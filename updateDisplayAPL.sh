#!/bin/bash

while [ 1 ]
do
        convert LMRK_DISPLAY1.pgm /Library/WebServer/Documents/data/landmarks.jpg
        convert LMRK_DISPLAY1.pgm /Library/WebServer/Documents/data/autoregister.jpg
        convert TEMPFILE.pgm /Library/WebServer/Documents/data/register.jpg
        sleep 2
done
