clear
clc

% Load the RGB image and convert it to gray-scale
im = imread('imgs/test-loremipsum.jpg');
global_vars
detect_im_paper
detect_markups
detect_chars_bounds