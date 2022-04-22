im = imread('../images/plat2.jpg');
imgray = rgb2gray(im);
imbin = imbinarize(imgray);
imedge = edge(imgray, 'sobel');

figure, imshow(im), title('im');
figure, imshow(imgray), title('imgray');
figure, imshow(imbin), title('imbin');
figure, imshow(imedge), title('imedge');

% Plate detection
Iprops = regionprops(imedge, 'BoundingBox', 'Area', 'Image');
area = Iprops.Area;
count = numel(Iprops);
maxa = area;
boundingBox = Iprops.BoundingBox;

for i = 1:count

    if maxa < Iprops(i).Area
        maxa = Iprops(i).Area;
        boundingBox = Iprops(i).BoundingBox;
    end

end

% Crop the plate
% imcr = imcrop(imbin, boundingBox);
% figure, imshow(imcr), title('imcr');

segments = segmentLetter(imgray);

letters = [];

[h, ~] = size(imgray);

for k = 1:length(segments)

    ow = length(segments(k).Image(1, :));
    oh = length(segments(k).Image(:, 1));
    % The height of bounding box should be in range (0.25*h, 0.8*h)
    % and its weight should be less than or equal with its height
    if oh < (0.8 * h) && oh > (0.25 * h) && ow <= oh
        thisBB = segments(k).BoundingBox;
        %     figure,imshow(imcrop(imcr, thisBB));
        rectangle(app.BoundingBoxImageAxes, 'Position', [thisBB(1), thisBB(2), thisBB(3), thisBB(4)], ...
        'EdgeColor', 'g', 'LineWidth', 2)

        thisLetter = segments(k).Image;

        detect = detectLetter(thisLetter);
        letters = [letters detect];
    end

end

disp("Detection Result:");
disp(letters);
