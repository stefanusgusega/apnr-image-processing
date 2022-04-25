function plateImg = detectPlate(imgIn)
    %detectPlate - Finds where the plate number is
    %
    % Syntax: plateImg = detectPlate(imgIn)
    %
    % This function takes an image as input and then return a greyscale of plate image

    % Convert image to grayscale first.
    imgray = im2gray(imgIn);

    [h, w] = size(imgray);

    diskSECoeff = max(1, round(1/30 * h));

    % Apply contrast enhancement using histogram equalization
    imhisteq = histeq(imgray);
    figure, imshow(imhisteq), title('imhisteq');

    % Morphological image opening
    SE = strel('disk', diskSECoeff);
    openedImg = imopen(imhisteq, SE);

    % Subtract operation
    subtracted = imsubtract(imhisteq, openedImg);

    % Image binarization using Otsu's method
    imbin = imbinarize(subtracted);

    % Edge detection using Sobel
    %imedge = edge(imbin, 'sobel');
    imedge = detect_edge(imbin, 'sobel', [], [], [], [], [], []);

    figure, imshow(subtracted), title('subtracted');
    figure, imshow(imedge), title('imedge');

    % Perform image dilation
    dilationSE = strel('line', 4, 45);
    dilated = imdilate(imedge, dilationSE);

    figure, imshow(dilated), title('dilated');

    % Fill the holes
    filled = imfill(dilated, 'holes');
    figure, imshow(filled), title('filled');

    % Morphological image opening onto the filled image
    openingSE2 = strel('disk', round(diskSECoeff / 2));
    openedImg2 = imopen(filled, openingSE2);
    figure, imshow(openedImg2), title('open 2');

    % Erode the opened image
    eroded = imerode(openedImg2, dilationSE);
    figure, imshow(eroded), title('eroded');

    regions = regionprops(eroded, 'BoundingBox', 'Area', 'Image');
    % disp(regions);

    boundingBox = getLargestBB(regions);

    imcr = imcrop(imgray, boundingBox);
    figure, imshow(imcr), title('imcr');

    croppedbin = imbinarize(imcr);

    % Get regions/bounding boxes
    % If the white part dominates, then apply negative filter to make background black
    % Then apply connected component analysis and bounding box analysis onto it
    if bwarea(croppedbin) > bwarea(~croppedbin)
        segments = regionprops(~croppedbin, 'BoundingBox', 'Area', 'Image');
        figure, imshow(~croppedbin), title('~croppedbin');

    else
        segments = regionprops(croppedbin, 'BoundingBox', 'Area', 'Image');
        figure, imshow(croppedbin), title('croppedbin');
    end

    finalBB = getLargestBB(segments);

    plateImg = imcrop(imcr, finalBB);
    figure, imshow(plateImg), title('plateImg');

end
