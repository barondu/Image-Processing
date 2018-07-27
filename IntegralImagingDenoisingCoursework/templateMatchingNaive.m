function [offsetsRows, offsetsCols, distances] = templateMatchingNaive(image,row, col,...
    patchSize, searchWindowSize)
% This function should for each possible offset in the search window
% centred at the current row and col, save a value for the offsets and
% patch distances, e.g. for the offset (-1,-1)
% offsetsRows(1) = -1;
% offsetsCols(1) = -1;
% distances(1) = 0.125;

% The distance is simply the SSD over patches of size patchSize between the
% 'template' patch centred at row and col and a patch shifted by the
% current offset

%REPLACE THIS
image = double(image);
dim = size(image,3);
norm_term = dim*(patchSize^2);

%centred patch
n = floor((patchSize-1)/2);
p0 = image(row-n:row+n,col-n:col+n,:);
%search window size
m = floor((searchWindowSize-1)/2);


offsetsRows = zeros(searchWindowSize,searchWindowSize);
offsetsCols = zeros(searchWindowSize,searchWindowSize);
distances = zeros(searchWindowSize,searchWindowSize);

for i = 1:searchWindowSize
    for j = 1:searchWindowSize
        
        %row-wise offset
        dRow = -m-1+i;
        offsetsRows(i,j) = dRow;
        %column-wise offset
        dCol = -m-1+j;
        offsetsCols(i,j) = dCol;
        
        %patch with offset
        p1 = image(col+dCol-n:col+dCol+n,row+dRow-n:row+dRow+n,:);
        
        %squared difference between offset and centre patchs
        distance = p0-p1;
        distance = distance.^2;
        
        %SSD between two patchs
        distances(i,j) = sum(distance(:));
        
    end
end

distances = distances/norm_term;
end