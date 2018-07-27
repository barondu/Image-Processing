function [ result_zero, result_import_gradient,result_mixing_gradient ] = poissonSolver( srcImg,targetImg,src_mask,target_mask )

%% pre-processing of the selected pixel index of src and target image
srcImg = double(srcImg)/255;
targetImg = double(targetImg)/255;

% get the index of the pixel in the image matrix
[bw_row,bw_col] = find(src_mask);
src_index = sub2ind(size(srcImg), bw_row, bw_col);

[bw_row,bw_col] = find(target_mask);
target_index = sub2ind(size(targetImg), bw_row, bw_col);

%% Build matrix A, |N_p|f_p-sum(f_q)
%--------------------------------------------------------------------------------
% get the number of pixel in selected area
dim = size(src_index,1);

% init the sparse matrix A, assign the diagnal with 4 (|N_p|)
% create 1xn sparse vector [4,4,...,4], and uses diag() to conver it into
% diagnal matrix, then combine with the 
A = diag(sparse(ones(1,dim)*4));

% iterate the selected area to fill the matrix
for k = 1:size(target_index,1)
    %get the x and y cordinates of current pixel
    index = target_index(k);
    [x,y] = ind2sub(size(targetImg),index);
    
    % handeling a_pipj values in the A matrix, check for 4 connected-neighbors
    % check (x-1,y)
    if(target_mask(x-1, y) == 1)
        % get the index of the neighbor pixel (x-1,y)
        neighbor_index=sub2ind(size(targetImg), x-1, y);
        
        % get the logical array of the neighbor pixel, where 1 is labeled
        % in this array to mark the index.
        % more efficient than using 'find(target_index==neighbor_index);'
        % to get the index. (Suggested by matlab hint)
        col_index=(target_index == neighbor_index);
        
        % assign -1 to corresponding position in the sparse matrix.
        A(k, col_index) = -1;
    end
    
    % check (x+1,y), apply same procedure
    if(target_mask(x+1, y) == 1)
        neighbor_index=sub2ind(size(targetImg), x+1, y);
        col_index=(target_index == neighbor_index);
        A(k, col_index) = -1;
    end
    
    % check (x,y-1), apply same procedure
    if(target_mask(x, y-1) == 1)
        neighbor_index=sub2ind(size(targetImg), x, y-1);
        col_index=(target_index == neighbor_index);
        A(k, col_index) = -1;
    end
    
    % check (x,y+1), apply same procedure
    if(target_mask(x, y+1) == 1)
        neighbor_index=sub2ind(size(targetImg), x, y+1);
        col_index=(target_index == neighbor_index);
        A(k, col_index) = -1;
    end    

end
%--------------------------------------------------------------------------------

%% Build vector b, where b = sum(f*)+sum(v_pq)

% **** Build sum(f*), where f* is scalar funtion defined over S minus
% interior of PI ****
%--------------------------------------------------------------------------------
f_star = targetImg;
% same as replacing the selected with 0
f_star(target_mask(:)==1)=0;

% We need to take the sum of conneted-neighbor pixels if pixel q belong to 
% the doundary of PI.(7) If q belong to interior of PI, then apply equation
% (8), take value of 0.
% Hence we can apply a kernel to sum the conneted-neighbor in f*
kernel = [0,1,0;1,0,1;0,1,0];
sum_f_star = imfilter(f_star, kernel, 'replicate');

% take selected area of sum(f*)
b_f_star = sum_f_star(target_index);
%--------------------------------------------------------------------------------

% **** Building sum(v_pq) part of vector b.****
%--------------------------------------------------------------------------------

% equation(2), task 1 where sum(v_pq) = 0;
v_zero=zeros(size(target_index));

% Importing gradients, where v_pq = gp-gq,(a)
kernel = [0 -1 0;-1 4 -1; 0 -1 0];
gradient = imfilter(srcImg,kernel,'replicate');

% take the selected area
v_gradient =gradient(src_index);

% Mixing gradients, where v_pq = f*_p-f*_q or gp-gq depending on their
% magnitue.
v_mix = v_zero;

for k = 1:size(target_index,1)
    sum_v=0;
    % get the index of the pixel in its source
    g_index = src_index(k);
    f_index=target_index(k);
    
    % get the x,y coordinate of selected pixel
    [gx,gy]=ind2sub(size(srcImg),g_index);
    [fx,fy]=ind2sub(size(targetImg),f_index);
    
    % get the g_p and f*_p value, the pixel itself
    gp=srcImg(gx,gy);
    fp=targetImg(fx,fy);
    
    % get the g_q and f*_q value, the neighbor pixel
    gq = srcImg(gx-1,gy);
    fq = targetImg(fx-1,fy);
    
    % if |fp-fq|>|gp-gq|, then v_pq=fp-fq, otherwise take v_pq=gp-gq
    if(abs(fp-fq)>abs(gp-gq))
        sum_v = sum_v + fp - fq;
    else
        sum_v = sum_v + gp - gq;
    end
    
    % repeat this procdure for other neighbors
    gq = srcImg(gx+1,gy);
    fq = targetImg(fx+1,fy);
    
    if(abs(fp-fq)>abs(gp-gq))
        sum_v = sum_v + fp - fq;
    else
        sum_v = sum_v + gp - gq;
    end    

    gq = srcImg(gx,gy-1);
    fq = targetImg(fx,fy-1);
    
    if(abs(fp-fq)>abs(gp-gq))
        sum_v = sum_v + fp - fq;
    else
        sum_v = sum_v + gp - gq;
    end    

    gq = srcImg(gx,gy+1);
    fq = targetImg(fx,fy+1);
    
    if(abs(fp-fq)>abs(gp-gq))
        sum_v = sum_v + fp - fq;
    else
        sum_v = sum_v + gp - gq;
    end
    
    % sum the neighbor result of v_qp up
    v_mix(k)=sum_v;
    
end

%--------------------------------------------------------------------------------

% **** Combine b = sum(f*)+sum(v_pq) ****
%--------------------------------------------------------------------------------
b_zero = b_f_star+v_zero;
b_gradient = b_f_star+v_gradient;
b_mix = b_f_star+v_mix;
%--------------------------------------------------------------------------------

%% Solving Ax=b, x = A\b
%--------------------------------------------------------------------------------
f_zero = A\b_zero;

f_gradient=A\b_gradient;

f_mix = A\b_mix;

%--------------------------------------------------------------------------------

%% Rebuild the result image
result_zero = targetImg;
result_zero(target_index)=f_zero;
result_zero = uint8(result_zero*255);

result_import_gradient = targetImg;
result_import_gradient(target_index)=f_gradient;
result_import_gradient=uint8(result_import_gradient*255);

result_mixing_gradient = targetImg;
result_mixing_gradient(target_index)=f_mix;
result_mixing_gradient=uint8(result_mixing_gradient*255);
end

