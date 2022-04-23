function plateImg = detectPlate(imgIn)
    %detectPlate - Finds where the plate number is
    %
    % Syntax: plateImg = detectPlate(imgIn)
    %
    % This function takes an image as input and then return a greyscale of plate image

    % Convert image to grayscale first.
    imgray = rgb2gray(imgIn);

    % Apply contrast enhancement using histogram equalization
    imhisteq = histeq(imgray);

    % Morphological image opening
    SE = strel('disk', 15);
    openedImg = imopen(imhisteq, SE);

    % Subtract operation
    subtracted = imsubtract(imhisteq, openedImg);

    % Image binarization using Otsu's method
    imbin = imbinarize(subtracted);

    % Edge detection using Sobel
    imedge = edge(imbin, 'sobel');

    figure, imshow(subtracted);
    figure, imshow(imedge);

    % Perform image dilation
    dilationSE = strel('line', 3, 45);
    dilated = imdilate(imedge, dilationSE);

    % Fill the holes
    filled = imfill(dilated, 'holes');

    % Erode the filled image
    eroded = imerode(filled, dilationSE);
    imshow(eroded);

end
