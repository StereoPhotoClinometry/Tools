#!/bin/bash

while [ 1 ]
do
        magick LMRK_DISPLAY1.pgm /Library/WebServer/Documents/data/landmarks.jpg
        magick LMRK_DISPLAY1.pgm /Library/WebServer/Documents/data/autoregister.jpg
        magick TEMPFILE.pgm /Library/WebServer/Documents/data/register.jpg
        sleep 2
done
