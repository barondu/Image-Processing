function [offsetsRows, offsetsCols, distances] = templateMatchingIntegralImage(image,row,...
    col,patchSize, searchWindowSize)
% This function should for each possible offset in the search window
% centred at the current row and col, save a value for the offsets and
% patch distances, e.g. for the offset (-1,-1)
% offsetsX(1) = -1;
% offsetsY(1) = -1;
% distances(1) = 0.125;

% The distance is simply the SSD over patches of size patchSize between the
% 'template' patch centred at row and col and a patch shifted by the
% current offset

% This time, use the integral image method!
% NOTE: Use the 'computeIntegralImage' function developed earlier to
% calculate your integral images
% NOTE: Use the 'evaluateIntegralImage' function to calculate patch sums

%REPLACE THIS
image = double(image);
dim = size(image,3);
norm_term = dim*(patchSize^2);

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

        %the offset image with translation
        offsetImage = imtranslate(image,[-dRow,-dCol]);
        %per-pixel SSD of the entrie image
        differenceImage = (image - offsetImage).^2;
        %Integral of Image of the differenceImage
        ii = computeIntegralImage(differenceImage);
        %Evaluate SSD of the pathch at given row and column
        distance = evaluateIntegralImage(ii, row, col, patchSize);
        
        distances(i,j) =sum(distance,3);
    end    
end

distances =distances/norm_term;

end