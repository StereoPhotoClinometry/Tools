#!/bin/bash

while read line
do
magick -contrast-stretch 80%x0.001%  ${line} ${line}.png
done <last6.txt

montage -geometry 1600x1600 -tile 3x2 *png ./last6images.png