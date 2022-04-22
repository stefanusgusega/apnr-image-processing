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

% Get the size of the image
[h, w] = size(imbin)

% Clean the small objects that have pixel area less than 0.1% of image area
imclean = bwareaopen(imbin, round(0.001 * h * w));
figure, imshow(imclean), title('imclean');

figure, imshow(~imbin), title('imbin');

% Get regions/bounding boxes
% If the white part dominates, then apply negative filter to make background black
% Then apply connected component analysis and bounding box analysis onto it
if bwarea(imclean) > bwarea(~imclean)
    st = regionprops(~imclean, 'BoundingBox', 'Area', 'Image');
else
    st = regionprops(imclean, 'BoundingBox', 'Area', 'Image');
end
letters = [];
for k = 1:length(st)
    

    ow = length(st(k).Image(1, :))
    oh = length(st(k).Image(:, 1))
    % The height of bounding box should be in range (0.2*h, 0.8*h)
    % and its weight should be less than or equal with its height
    if oh < (0.8 * h) && oh > (0.2 * h) && ow <= oh
        thisBB = st(k).BoundingBox;
        %     figure,imshow(imcrop(imcr, thisBB));
        rectangle('Position', [thisBB(1), thisBB(2), thisBB(3), thisBB(4)], ...
        'EdgeColor', 'g', 'LineWidth', 2)

        thisLetter = st(k).Image;

        detect = detectLetter(thisLetter);
        letters = [letters detect];
    end

end

disp("Detection Result:");
disp(letters);

