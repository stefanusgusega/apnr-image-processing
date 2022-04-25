im = imread('../images/1.jpg');
plateIm = detectPlate(im);
imshow(plateIm);
segments = segmentLetter(plateIm);

letters = [];

[h, ~] = size(plateIm);

for k = 1:length(segments)

    ow = length(segments(k).Image(1, :));
    oh = length(segments(k).Image(:, 1));
    % The height of bounding box should be in range (0.25*h, 0.8*h)
    % and its weight should be less than or equal with its height
    if 1
        thisBB = segments(k).BoundingBox;
        %     figure,imshow(imcrop(imcr, thisBB));
        rectangle('Position', [thisBB(1), thisBB(2), thisBB(3), thisBB(4)], ...
        'EdgeColor', 'g', 'LineWidth', 2)

        thisLetter = segments(k).Image;

        detect = detectLetter(thisLetter);
        letters = [letters detect];
    end

end

disp(letters);