function [result] = computeWeighting(d, h, sigma, patchSize)
    %Implement weighting function from the slides
    %Be careful to normalise/scale correctly!
    
    % normalise term 3(2r+1)^2
    dim = size(d,3);
    norm_term =dim*(patchSize^2);
    
    % summing up the distance in 3 color channels
    d = sum(d,3)/(norm_term);
    
    h2 = h*h;
    sigma2 = 2*sigma*sigma;

    result = exp(-max(d-sigma2,0)/h2);
end