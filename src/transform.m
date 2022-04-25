function [transformed_arr] = transform(histogram, total_pixel)
    %TRANSFORM Transform the known histogram that leads to histogram equalization
    % Goal: create T(rk)

    % create T(rk) 
    transformed_arr = zeros(256, 1);

    % calculate probability for each rk
    for i = 1:256 
        sum = 0;
        for j = 1:i
            sum = sum + histogram(j)/total_pixel;
        end
        transformed_arr(i) = floor(sum*255);
    end
end