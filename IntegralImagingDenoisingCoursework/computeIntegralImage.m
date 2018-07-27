function [ii] = computeIntegralImage(image)

%Uses cumsum is more efficient

%Type casting from int8 to double, otherwise can not store intensity
%greater than 255
image = double(image);
%Add up the pixel values cumulativitly for each column
cumSumCol = cumsum(image);
%Add up the row-wise cumulative sum for each row
ii = cumsum(cumSumCol , 2);

%[m n ~]=size(image);

%ii=zeros(size(image));

%for i=1:m
    %for j=1:n
        % copy the first pixel directly
        %if i==1 && j==1            
            %ii(i,j,:)=image(i,j,:);
        % first row values are cumlative sum from left to right
        %else if i==1 && j~=1         
            %ii(i,j,:)=ii(i,j-1,:)+image(i,j,:);
        % first column?values are cumlative sum from top to bottom
        %else if i~=1 && j==1         
            %ii(i,j,:)=ii(i-1,j,:)+image(i,j,:);
        % other case the integal value is calculated by summing current
        % pixel value with top and left then subtract by top-left
        %else                        
            %ii(i,j,:)=image(i,j,:)+ii(i-1,j,:)+ii(i,j-1,:)-ii(i-1,j-1,:);  
        %end
    %end
%end

end