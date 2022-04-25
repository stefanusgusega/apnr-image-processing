function bb = getLargestBB(segments)
    %getLargestBB - Description
    %
    % Syntax: bb = getLargestBB(segments)
    %
    % Long description

    maxa = segments.Area;
    bb = segments.BoundingBox;

    for i = 1:length(segments)

        if segments(i).Area > maxa
            maxa = segments(i).Area;
            bb = segments(i).BoundingBox;
        end

    end

end
