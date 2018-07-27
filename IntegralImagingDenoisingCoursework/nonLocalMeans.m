function [result] = nonLocalMeans(image, sigma, h, patchSize, windowSize)

image = double(image);
denoiseImage = zeros(size(image));

%get the r from window size 2r+1
n = floor((patchSize-1)/2);
m = floor((windowSize-1)/2);

% pad the source image to handle borders
paddedImage = padarray(image,[m,m],'symmetric','both');
% pad the source image to get offsets
paddedOffset = padarray(image,[m+n+1,m+n+1],'symmetric','both');
% store the total weight of each offsets 
sumWeight=denoiseImage;  

% loop over the search window
for dRow = -m:m
    for dCol = -m:m
        
        %ignore the offset (0,0)
        if(dRow==0&&dCol==0)
            continue;
        end

        %per-pixel SSD of the entrie image
        differenceImage = (paddedOffset(1+m:end-m,1+m:end-m,:)-paddedOffset(1+m+dRow:end-m+dRow,1+m+dCol:end-m+dCol,:)).^2;
        
        %Integral of Image of the differenceImage
        II = computeIntegralImage(differenceImage);
        
        %Un-normalised SSD with of each pixels within each patch
        distance = II(patchSize+1:end-1,patchSize+1:end-1,:)+II(1:end-patchSize-1,1:end-patchSize-1,:)...  
               -II(patchSize+1:end-1,1:end-patchSize-1,:)-II(1:end-patchSize-1,patchSize+1:end-1,:);
           
        %Weight of each patch
        weight = computeWeighting(distance,h,sigma,patchSize);
        
        %Get the noise pixel q
        noise = paddedImage(1+m+dRow:end-m+dRow,1+m+dCol:end-m+dCol,:);
        
        %summing up the weighted noise
        denoiseImage = denoiseImage+(noise.*weight);
        
        %summing up the weights
        sumWeight=sumWeight+weight;  
            
    end
end
% normalise by C(P) 
denoiseImage=denoiseImage./sumWeight;  

% cast the result to uint for display
result = uint8(denoiseImage);


end