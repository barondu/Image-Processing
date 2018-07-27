function [src_mask,target_mask] = selectRegion(srcImg,targetImg)

% Mark out selected region in source image
[src_mask,xi,yi] = roipoly(srcImg);

figure,imshow(targetImg);

% drag the selected region in target image
roi =impoly(gca,[xi,yi]);
wait(roi);

% get the resulting drag position
positions = roi.getPosition;

% calculates the change in row and col
% no scaling, only simple translations
dRow = positions(1,1)-xi(1);
dCol = positions(1,2)-yi(1);

% create the target mask by shifting the src mask by the change in position
[row,col,~] = size(targetImg);
target_mask = zeros(row,col);
% get row and col index of non-zero pixels
[row,col]=find(src_mask);
[targetRow,targetCol]=size(targetImg);

% assign 1 to corresponding translated pixel in the target mask
target_mask(sub2ind([targetRow,targetCol],round(row+dCol),round(col+dRow)))=1;
target_mask=logical(target_mask);
end

