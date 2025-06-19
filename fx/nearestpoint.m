function [x,y] = nearestpoint(lon,lat,qlon,qlat)
    % Calculate the distances between the query point and all data points
    distances   = sqrt((lat(:) - qlat).^2 + (lon(:) - qlon).^2);

    % Find the indexes of the closest points
    [~, idx]    = min(distances);

    % Convert the linear index to row and column indices
    [x, y]      = ind2sub(size(lat), idx);
end