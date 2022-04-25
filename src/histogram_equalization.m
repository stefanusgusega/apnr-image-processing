function [imgOut] = histogram_equalization(imgIn)
%HISTOGRAM_EQUALIZATION Equalize the histogram distribution of an image

    % output initialization
    imgOut = imgIn;
    %hix = imgIn;

    % image size
    [row, col, depth] = size(imgIn);
    n = row * col;
    
    %imgArr = imgIn(:,:,d);
    histogram = imhist(imgIn);

    % create T(rk) 
    histFunc = transform(histogram, n);
    
    % transform image based on T(rk)
    for i = 1:row
        for j = 1:col
            imgOut(i,j) = histFunc(imgIn(i,j)+1);
        end
    end
end