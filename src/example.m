im = imread('../images/plat1.jpg');
imgray = rgb2gray(im);
imbin = imbinarize(imgray);
imedge = edge(imgray, 'prewitt');

%figure,imshow(im);
%figure,imshow(imgray);
%figure,imshow(imbin);
%figure,imshow(imedge);

Iprops = regionprops(imedge, 'BoundingBox', 'Area','Image');
area = Iprops.Area;
count = numel(Iprops);
maxa = area;
boundingBox = Iprops.BoundingBox;
for i=1:count
    if maxa<Iprops(i).Area
        maxa = Iprops(i).Area;
        boundingBox = Iprops(i).BoundingBox;
    end
end

imcr = imcrop(imbin, boundingBox);
imclean = bwareaopen(imcr, 500);
%figure, imshow(imcr);
figure, imshow(imclean);

st = regionprops(imclean, 'BoundingBox', 'Area', 'Image');

for k = 1: length(st)
    ow = length(st(k).Image(1, :))
    oh = length(st(k).Image(:, 1))
    thisBB = st(k).BoundingBox;
    figure,imshow(imcrop(imclean, thisBB));
    rectangle('Position', [thisBB(1), thisBB(2), thisBB(3), thisBB(4)],...
    'EdgeColor','g','LineWidth',2)
end
