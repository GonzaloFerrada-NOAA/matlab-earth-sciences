function data_out = aggregatedata(lon_in, lat_in, data, lon_out, lat_out, opt)
%AGGREGATEDATA Aggregate gridded or scattered data onto a target lon/lat grid
%
%   data_out = aggregatedata(lon_in, lat_in, data, lon_out, lat_out, opt)
%
%   Aggregates input data defined on an arbitrary longitude/latitude grid
%   (or as scattered points) onto a new regular lon/lat grid defined by
%   lon_out and lat_out. Aggregation is performed by assigning each input
%   point to the nearest target grid-cell center and applying the requested
%   reduction operator.
%
%   Inputs
%   ------
%   lon_in  : Input longitudes. Can be:
%               - 1-D vector (length nlon)
%               - 2-D array (same size as data)
%   lat_in  : Input latitudes. Can be:
%               - 1-D vector (length nlat)
%               - 2-D array (same size as data)
%   data    : Input data values.
%               - 2-D array (nlon x nlat or nlat x nlon)
%               - Vector of scattered values (same number of elements as lon_in)
%   lon_out : 1-D vector of target longitude grid centers (regular spacing)
%   lat_out : 1-D vector of target latitude  grid centers (regular spacing)
%   opt     : Aggregation operator (char or string):
%               'mean'  → arithmetic mean of all points in each grid cell
%               'sum'   → sum of all points in each grid cell
%
%   Output
%   ------
%   data_out : 2-D array of size [length(lon_out), length(lat_out)]
%              containing the aggregated data on the target grid.
%              Grid cells with no contributing data are set to NaN.
%
%   Behavior and Notes
%   ------------------
%   - If lon_in and lat_in are 1-D vectors and data is 2-D, the function
%     expands lon/lat using NDGRID. Transposed data arrays are detected
%     and corrected automatically.
%   - Input points are assigned to the nearest target grid-cell center
%     using ROUND-based indexing (not FLOOR), avoiding half-cell shifts.
%   - Only data within half a grid-cell of the outermost lon_out/lat_out
%     centers are retained; points outside this extended domain are ignored.
%   - No longitude wrapping is applied (e.g., [-180,180] vs [0,360] must
%     already be consistent between input and output grids).
%   - NaNs in the input data are preserved by the aggregation operator.
%
%   Example
%   -------
%   % Aggregate high-resolution data to a 2.5° global grid
%   lon_out = -178.75:2.5:178.75;
%   lat_out = -88.75:2.5:88.75;
%   data_agg = aggregatedata(lon, lat, data, lon_out, lat_out, 'mean');
%
%   See also ACCUMARRAY, NDGRID, ROUND
    
    % If lon/lat are 1-D vectors but data is a 2-D grid, expand lon/lat to 2-D.
    if isvector(lon_in) && isvector(lat_in) && ~isvector(data)
        nlon = numel(lon_in);
        nlat = numel(lat_in);

        if isequal(size(data), [nlon nlat])
            [lon_in, lat_in] = ndgrid(lon_in, lat_in);
        elseif isequal(size(data), [nlat nlon])
            % If data is transposed relative to lon/lat, fix it
            data = data.';
            [lon_in, lat_in] = ndgrid(lon_in, lat_in);
        else
            error('Size mismatch: data is %dx%d, expected %dx%d (or %dx%d).', ...
                size(data,1), size(data,2), nlon, nlat, nlat, nlon);
        end
    end
    
    % Ensure column vectors
    lon_in = lon_in(:);
    lat_in = lat_in(:);
    data = data(:);

    % Resolution
    dlon = mean(diff(lon_out));
    dlat = mean(diff(lat_out));

    % --- FIX 1: Allow data within half-width of the edge centers ---
    % Previous logic deleted everything < -177.5 or > 177.5
    in_region = lon_in >= (min(lon_out) - dlon/2) & lon_in <= (max(lon_out) + dlon/2) & ...
                lat_in >= (min(lat_out) - dlat/2) & lat_in <= (max(lat_out) + dlat/2);
                
    lon_in = lon_in(in_region);
    lat_in = lat_in(in_region);
    data   = data(in_region);

    % --- FIX 2: Use ROUND to align to grid centers (You implemented this correctly) ---
    % floor() shifts the grid by half a cell (2.5 deg)
    lon_idx = round((lon_in - lon_out(1)) / dlon) + 1;
    lat_idx = round((lat_in - lat_out(1)) / dlat) + 1;

    % Safety check for indices (keeps code robust against floating point errors)
    valid_idx = lon_idx >= 1 & lon_idx <= length(lon_out) & ...
                lat_idx >= 1 & lat_idx <= length(lat_out);
                
    lon_idx = lon_idx(valid_idx);
    lat_idx = lat_idx(valid_idx);
    data    = data(valid_idx);

    % Combine into subscripts
    subs = [lon_idx, lat_idx];

    % Grid size
    nlat = length(lat_out);
    nlon = length(lon_out);

    % Aggregate
    switch opt
    case 'mean'
        data_out = accumarray(subs, data, [nlon, nlat], @mean, NaN);
    case 'sum'
        data_out = accumarray(subs, data, [nlon, nlat], @sum, NaN);
    end
end

% function data_out = aggregatedata(lon_in, lat_in, data, lon_out, lat_out)
% %AGGREGATEDATA Aggregates scattered data onto a regular lon-lat grid.
% %
% %   data_out = aggregatedata(lon_in, lat_in, data, lon_out, lat_out)
% %
% %   Inputs:
% %       lon_in, lat_in : 1-D arrays of input coordinates
% %       data           : 1-D array of data values
% %       lon_out        : 1-D array of target longitudes (e.g., -179.5:1:179.5)
% %       lat_out        : 1-D array of target latitudes (e.g., -89.5:1:89.5)
% %
% %   Output:
% %       data_out       : 2-D matrix (lat x lon) of aggregated data (mean),
% %                        with NaNs for grid cells with no data

%     % Ensure column vectors
%     lon_in = lon_in(:);
%     lat_in = lat_in(:);
%     data = data(:);

%     % Remove points outside defined grid
%     in_region = lon_in >= min(lon_out) & lon_in <= max(lon_out) & ...
%                 lat_in >= min(lat_out) & lat_in <= max(lat_out);
%     lon_in = lon_in(in_region);
%     lat_in = lat_in(in_region);
%     data = data(in_region);

%     % Resolution assumed uniform
%     dlon = mean(diff(lon_out));
%     dlat = mean(diff(lat_out));

%     % Compute indices into grid
%     lon_idx = floor((lon_in - lon_out(1)) / dlon) + 1;
%     lat_idx = floor((lat_in - lat_out(1)) / dlat) + 1;

%     % Combine into subscripts
%     subs = [lon_idx, lat_idx];

%     % Grid size
%     nlat = length(lat_out);
%     nlon = length(lon_out);

%     % Aggregate using mean
%     data_out = accumarray(subs, data, [nlon, nlat], @mean, NaN);
% end