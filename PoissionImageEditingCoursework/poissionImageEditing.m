close all;
clear;
clc;

% load in the source and target images
TargetImg = imread('images/dolphin.jpg');
SourceImg = imread('images/dog.jpg');

figure, imshow(SourceImg),axis image;
% select the source and target region and get their mask
[src_mask,target_mask] = selectRegion(SourceImg,TargetImg);

% get the boundries of these mask
src_boundry = bwboundaries(src_mask,8);
target_boundry = bwboundaries(target_mask,8);

[ar,br,cr] = poissonSolver(SourceImg(:,:,1),TargetImg(:,:,1),src_mask,target_mask);
[ag,bg,cg] = poissonSolver(SourceImg(:,:,2),TargetImg(:,:,2),src_mask,target_mask);
[ab,bb,cb] = poissonSolver(SourceImg(:,:,3),TargetImg(:,:,3),src_mask,target_mask);

figure;
imshow(cat(3,ar,ag,ab));
title('task 1');
figure;
imshow(cat(3,br,bg,bb));
title('importing gradient');
figure;
imshow(cat(3,cr,cg,cb));
title('mixing gradient');

%% ploting the orginal images and their masks
figure;
subplot(2,2,1);
imshow(SourceImg);

hold on
for k=1:length(src_boundry)
    boundary=src_boundry{k};
    plot(boundary(:,2),boundary(:,1),'r','LineWidth',2);
end
hold off
title('source outline');
axis image;

subplot(2,2,2);
imshow(src_mask);
title('source mask');
axis image;

subplot(2,2,3);
imshow(TargetImg);

hold on
for k=1:length(target_boundry)
    boundary=target_boundry{k};
    plot(boundary(:,2),boundary(:,1),'r','LineWidth',2);
end
hold off
title('target outline');
axis image;

subplot(2,2,4);
imshow(target_mask);
axis image;
title('target mask');