function bb = getLargestBB(segments)
    %getLargestBB - Description
    %
    % Syntax: bb = getLargestBB(segments)
    %
    % Long description

    maxa = segments.Area;
    bb = segments.BoundingBox;

    for i = 1:length(segments)
        ow = length(segments(i).Image(1, :));
        oh = length(segments(i).Image(:, 1));

        if (segments(i).Area > maxa) & oh < ow
            maxa = segments(i).Area;
            bb = segments(i).BoundingBox;
        end

    end

end
