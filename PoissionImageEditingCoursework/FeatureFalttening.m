close all;
clear;
clc;

I = imread('images/trump.jpg');

I_mask = roipoly(I);

R = fetureFlatten(I(:,:,1),I_mask,0.05);
G = fetureFlatten(I(:,:,2),I_mask,0.05);
B = fetureFlatten(I(:,:,3),I_mask,0.05);

imshow(cat(3,R,G,B));