function [x,y] = ll2sin(lon,lat)
    lon0 = 0;
    x    = (lon - lon0) .* cosd(lat);
    y    = lat;
end