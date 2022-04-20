im = imread('../images/plat2.jpg');
imgray = rgb2gray(im);
imbin = imbinarize(imgray);
imedge = edge(imgray, 'prewitt');

figure,imshow(im),title('im');
figure,imshow(imgray),title('imgray');
figure,imshow(imbin),title('imbin');
figure,imshow(imedge),title('imedge');

% Plate detection
Iprops = regionprops(imedge, 'BoundingBox', 'Area','Image');
area = Iprops.Area;
count = numel(Iprops);
maxa = area;
boundingBox = Iprops.BoundingBox;
for i=1:count
    if maxa < Iprops(i).Area
        maxa = Iprops(i).Area;
        boundingBox = Iprops(i).BoundingBox;
    end
end

% Crop the plate
imcr = imcrop(imbin, boundingBox);
figure, imshow(imcr), title('imcr');

% Clean the small objects that have pixel area less than 500
imclean = bwareaopen(~imbin, 500);
figure, imshow(imclean), title('imclean');

% figure,imshow(imbin),title('imbin');

% Get regions/bounding boxes
st = regionprops(imclean, 'BoundingBox', 'Area', 'Image');

% Draw the box
for k = 1: length(st)
    ow = length(st(k).Image(1, :))
    oh = length(st(k).Image(:, 1))
    % If the area of rectangle more than 500 pixels, then draw the rect
    if ow*oh >= 500
        thisBB = st(k).BoundingBox;
%     figure,imshow(imcrop(imcr, thisBB));
        rectangle('Position', [thisBB(1), thisBB(2), thisBB(3), thisBB(4)],...
        'EdgeColor','g','LineWidth',2)
    end
    
end
