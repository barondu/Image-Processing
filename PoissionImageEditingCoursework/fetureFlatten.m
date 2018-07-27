function [ resultImg ] = fetureFlatten(srcImg,srcMask,T)
srcImg = double(srcImg);
% Prewitt kernel, can be replaced by sobel or other kernels
kernel = [-1,0,1;-1,0,1;-1,0,1];
gx = imfilter(srcImg, kernel, 'conv');
gy = imfilter(srcImg, kernel', 'conv');
g = sqrt(gx.^2 + gy.^2);

% normalize g magnitude
g = g/max(g(:));

% get the edge mask based on thereshold we set 
edge_mask = g>T;

% perpare image
srcImg = double(srcImg)/255;
[bw_row,bw_col] = find(srcMask);
src_index = sub2ind(size(srcImg), bw_row, bw_col);

% Build A
% get the number of pixel in selected area
dim = size(src_index,1);
A = diag(sparse(ones(1,dim)*4));

for k = 1:size(src_index,1)

    index = src_index(k);
    [x,y] = ind2sub(size(srcImg),index);
    
    if(srcMask(x-1, y) == 1)
        neighbor_index=sub2ind(size(srcImg), x-1, y);
        col_index=(src_index == neighbor_index);
        A(k, col_index) = -1;
    end
    
    if(srcMask(x+1, y) == 1)
        neighbor_index=sub2ind(size(srcImg), x+1, y);
        col_index=(src_index == neighbor_index);
        A(k, col_index) = -1;
    end
    
    if(srcMask(x, y-1) == 1)
        neighbor_index=sub2ind(size(srcImg), x, y-1);
        col_index=(src_index == neighbor_index);
        A(k, col_index) = -1;
    end
    
    if(srcMask(x, y+1) == 1)
        neighbor_index=sub2ind(size(srcImg), x, y+1);
        col_index=(src_index == neighbor_index);
        A(k, col_index) = -1;
    end    

end

% Build b
f_star = srcImg;

% build sum(f*) terms
f_star(srcMask(:)==1)=0;
kernel = [0,1,0;1,0,1;0,1,0];
sum_f_star = imfilter(f_star, kernel, 'replicate');

b_f_star = sum_f_star(src_index);

v=zeros(size(src_index));

% build v = fq-fp when there are edge between q and p
for k = 1:size(src_index,1)
    sum_v=0;

    f_index = src_index(k);
    [fx,fy]=ind2sub(size(srcImg),f_index);
    
    fp=srcImg(fx,fy);
    
    % get the boolean mask for q and p
    edge_p = edge_mask(fx,fy);
    edge_q = edge_mask(fx-1,fy);
    
    % if they are both true, then take the fq-fp as v, otherwise leave it
    % as 0.
    if edge_p&&edge_q
        sum_v = sum_v +fp-srcImg(fx-1,fy);
    end
    % repeat for neighbors
    edge_q = edge_mask(fx+1,fy);
    
    if edge_p&&edge_q
        sum_v = sum_v +fp-srcImg(fx+1,fy);
    end
    
    edge_q = edge_mask(fx,fy-1);
    
    if edge_p&&edge_q
        sum_v = sum_v +fp-srcImg(fx,fy-1);
    end

    edge_q = edge_mask(fx,fy+1);
    
    if edge_p&&edge_q
        sum_v = sum_v +fp-srcImg(fx,fy+1);
    end

    v(k)=sum_v;
    
end

% sum up the b term
b = b_f_star+v;

% x=A\b
f = A\b;

resultImg = srcImg;
resultImg(src_index)=f;
resultImg = uint8(resultImg*255);
end

