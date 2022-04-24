function plateImg = detectPlate(imgIn)
    %detectPlate - Finds where the plate number is
    %
    % Syntax: plateImg = detectPlate(imgIn)
    %
    % This function takes an image as input and then return a greyscale of plate image

    % Convert image to grayscale first.
    imgray = rgb2gray(imgIn);

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
    imedge = edge(imbin, 'sobel');

    figure, imshow(subtracted), title('subtracted');
    figure, imshow(imedge), title('imedge');

    % Perform image dilation
    dilationSE = strel('line', 7, 45);
    dilated = imdilate(imedge, dilationSE);

    figure, imshow(dilated), title('dilated');

    % Fill the holes
    filled = imfill(dilated, 'holes');
    figure, imshow(filled), title('filled');

    % Morphological image opening onto the filled image
    openingSE2 = strel('disk', diskSECoeff);
    openedImg2 = imopen(filled, openingSE2);
    figure, imshow(openedImg2), title('open 2');

    % Erode the opened image
    eroded = imerode(openedImg2, dilationSE);
    figure, imshow(eroded), title('eroded');

    regions = regionprops(eroded, 'BoundingBox', 'Area', 'Image');
    % disp(regions);

    area = regions.Area;
    maxa = area;
    boundingBox = regions.BoundingBox;

    for i = 1:length(regions)

        if regions(i).Area > maxa
            maxa = regions(i).Area;
            boundingBox = regions(i).BoundingBox;
        end

    end

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

    finalBB = segments(1).BoundingBox;

    plateImg = imcrop(imcr, finalBB);
    figure, imshow(plateImg), title('plateImg');

end
