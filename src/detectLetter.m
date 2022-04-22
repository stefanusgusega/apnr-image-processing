function letter = detectLetter(imgIn)
    %   Detect Letter using template matching
    %

    % load templates
    load newTemplates;
    tempLabel = [
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', ...
                'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', ...
                '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
            ];
    col = 24;

    % resize input image
    imgIn = imresize(imgIn, [42 24]);

    rec = [];

    for n = 1:36
        % access one template
        temp = imbinarize(newTemplates(:, ((n - 1) * col) + 1:n * col));

        % find correlation
        cor = corr2(temp, imgIn);

        % append correlation
        rec = [rec cor];
    end

    % find index with maximum correlation
    ind = find(rec == max(rec));

    % find label
    letter = tempLabel(ind);

end
