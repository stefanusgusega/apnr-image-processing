im = imread('../images/plat3.jpg');
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

letters = segmentRecognizeLetter(imgray);

disp("Detection Result:");
disp(letters);
