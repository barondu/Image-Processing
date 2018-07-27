%% Some parameters to set - make sure that your code works at image borders!
close all;
% Row and column of the pixel for which we wish to find all similar patches 
% NOTE: For this section, we pick only one patch
row = 10;
col = 10;

% Patchsize - make sure your code works for different values
n = 1;
patchSize = 2*n+1;

% Search window size - make sure your code works for different values
n = 5;
searchWindowSize =2*n+1;


%% Implementation of work required in your basic section-------------------

% TODO - Load Image
image = imread('images/alleyNoisy_sigma20.png');
imshow(image);
% TODO - Fill out this function
image_ii = computeIntegralImage(image);

% TODO - Display the normalised Integral Image
% NOTE: This is for display only, not for template matching yet!
figure('name', 'Normalised Integral Image');

% make the image min starts from 0
ii_norm = image_ii - min(image_ii(:));
% normalise by the range of max-min, we get values in range [0,1]
ii_norm = ii_norm/(max(image_ii(:)) - min(image_ii(:)));
% mutiply by 255 to get range [0, 255]
ii_norm = 255*ii_norm;
% type casting to uint8 for display
ii_norm = uint8(ii_norm);
imshow(ii_norm);

% TODO - Template matching for naive SSD (i.e. just loop and sum)
[offsetsRows_naive, offsetsCols_naive, distances_naive] = templateMatchingNaive(image,row, col,...
    patchSize, searchWindowSize);

% TODO - Template matching using integral images
[offsetsRows_ii, offsetsCols_ii, distances_ii] = templateMatchingIntegralImage(image,row, col,...
    patchSize, searchWindowSize);

%% Let's print out your results--------------------------------------------

% NOTE: Your results for the naive and the integral image method should be
% the same!
for i=1:length(offsetsRows_naive)
    disp(['offset rows: ', num2str(offsetsRows_naive(i)), '; offset cols: ',...
        num2str(offsetsCols_naive(i)), '; Naive Distance = ', num2str(distances_naive(i),10),...
        '; Integral Im Distance = ', num2str(distances_ii(i),10)]);
end