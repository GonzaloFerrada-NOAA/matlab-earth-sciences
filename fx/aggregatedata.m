function data_out = aggregatedata(lon_in, lat_in, data, lon_out, lat_out)
%AGGREGATEDATA Aggregates scattered data onto a regular lon-lat grid.
%
%   data_out = aggregatedata(lon_in, lat_in, data, lon_out, lat_out)
%
%   Inputs:
%       lon_in, lat_in : 1-D arrays of input coordinates
%       data           : 1-D array of data values
%       lon_out        : 1-D array of target longitudes (e.g., -179.5:1:179.5)
%       lat_out        : 1-D array of target latitudes (e.g., -89.5:1:89.5)
%
%   Output:
%       data_out       : 2-D matrix (lat x lon) of aggregated data (mean),
%                        with NaNs for grid cells with no data

    % Ensure column vectors
    lon_in = lon_in(:);
    lat_in = lat_in(:);
    data = data(:);

    % Remove points outside defined grid
    in_region = lon_in >= min(lon_out) & lon_in <= max(lon_out) & ...
                lat_in >= min(lat_out) & lat_in <= max(lat_out);
    lon_in = lon_in(in_region);
    lat_in = lat_in(in_region);
    data = data(in_region);

    % Resolution assumed uniform
    dlon = mean(diff(lon_out));
    dlat = mean(diff(lat_out));

    % Compute indices into grid
    lon_idx = floor((lon_in - lon_out(1)) / dlon) + 1;
    lat_idx = floor((lat_in - lat_out(1)) / dlat) + 1;

    % Combine into subscripts
    subs = [lon_idx, lat_idx];

    % Grid size
    nlat = length(lat_out);
    nlon = length(lon_out);

    % Aggregate using mean
    data_out = accumarray(subs, data, [nlon, nlat], @mean, NaN);
end