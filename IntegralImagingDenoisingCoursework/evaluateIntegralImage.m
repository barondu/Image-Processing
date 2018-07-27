function [patchSum] = evaluateIntegralImage(ii, row, col, patchSize)
% This function should calculate the sum over the patch centred at row, col
% of size patchSize of the integral image ii

n = floor((patchSize-1)/2);
L1 = ii(row-n-1,col-n-1,:);
L2 = ii(row-n-1,col+n,:);
L3 = ii(row+n,col+n,:);
L4 = ii(row+n,col-n-1,:);

patchSum = L3-L2-L4+L1;

end