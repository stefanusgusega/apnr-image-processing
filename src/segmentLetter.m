function segments = segmentLetter(imgIn)
    %myFun - Description
    %
    % Syntax: output = myFun(input)
    %
    % Long description
    % Apply binarization towards the image
    imbin = imbinarize(imgIn);

    % Get the size of the image
    [h, w] = size(imbin);

    % Clean the small objects that have pixel area less than 0.1% of image area
    imclean = bwareaopen(imbin, round(0.001 * h * w));
    figure, imshow(imclean), title('imclean');

    figure, imshow(~imbin), title('imbin');

    % Get regions/bounding boxes
    % If the white part dominates, then apply negative filter to make background black
    % Then apply connected component analysis and bounding box analysis onto it
    if bwarea(imclean) > bwarea(~imclean)
        segments = regionprops(~imclean, 'BoundingBox', 'Area', 'Image');
    else
        segments = regionprops(imclean, 'BoundingBox', 'Area', 'Image');
    end

end
