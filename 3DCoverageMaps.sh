#!/bin/bash

# This script runs view_shapeA and creates images that
# show the shape and any areas covered by maplets. It
# copies the images into the SHAPEVIEWS directory and
# opens each image. 
#
# You must run shape_coverage before running this script!
# 
# Comments added by Terik Daly 12/30/20
# 4/9/21, Terik Daly: moved the open statements to the end.

echo "~~~~Running view_01~~~~"
cp geometry_01.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_01_cov.pgm


echo "~~~~Running view_02~~~~"
cp geometry_02.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_02_cov.pgm


echo "~~~~Running view_03~~~~"
cp geometry_03.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_03_cov.pgm


echo "~~~~Running view_04~~~~"
cp geometry_04.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_04_cov.pgm


echo "~~~~Running view_05~~~~"
cp geometry_05.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_05_cov.pgm


echo "~~~~Running view_06~~~~"
cp geometry_06.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_06_cov.pgm


echo "~~~~Running view_07~~~~"
cp geometry_07.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_07_cov.pgm


echo "~~~~Running view_08~~~~"
cp geometry_08.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_08_cov.pgm


echo "~~~~Running view_09~~~~"
cp geometry_09.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_09_cov.pgm


echo "~~~~Running view_10~~~~"
cp geometry_10.in geometry.in
view_shapeA
mv view.pgm SHAPEVIEWS/view_10_cov.pgm


open SHAPEVIEWS/view_*_cov.pgm

rm SHAPEFILES/*PLT
rm *DAT