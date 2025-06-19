function [X, Y] = ll2pers(longitude_degrees, latitude_degrees, center, Height_viewpoint)
    % ll2pers: Converts latitude and longitude to X, Y in General Perspective Projection
    %
    % Inputs:
    % - longitude_degrees: Array of longitudes (in degrees)
    % - latitude_degrees: Array of latitudes (in degrees)
    % - center: [center_lon, center_lat] (in degrees) defining the viewpoint center
    % - Height_viewpoint (optional): Height of viewpoint above Earth (default: 35,786 km)
    %
    % Outputs:
    % - X, Y: Projected coordinates in the General Perspective Projection
    %
    % Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
    % January 2025
    % Using equations as described in:
    % https://neacsu.net/docs/geodesy/snyder/5-azimuthal/sect_23/#formulas-for-the-sphere
    % plus adding a visibility filter to not plot data that is in the other side
    % of the world view

    % Constants
    R = 6378; % Radius of Earth in km

    % Default height if not provided
    if nargin < 4
        Height_viewpoint = 35786; % Default height in km
    end

    % Convert inputs to radians
    lon = deg2rad(longitude_degrees);
    lat = deg2rad(latitude_degrees);
    center_lon = deg2rad(center(1));
    center_lat = deg2rad(center(2));

    % Auxiliary variables
    rho = R + Height_viewpoint;
    cos_c = sin(center_lat) .* sin(lat) + cos(center_lat) .* cos(lat) .* cos(lon - center_lon);

    % Visibility condition
    visible = (rho * cos_c > R);

    % Initialize output
    X = nan(size(longitude_degrees));
    Y = nan(size(latitude_degrees));

    % Calculate projected coordinates for visible points
    if any(visible, 'all')
        denom = rho - R .* cos_c(visible);
        X(visible) = rho .* cos(lat(visible)) .* sin(lon(visible) - center_lon) ./ denom;
        Y(visible) = rho .* (cos(center_lat) .* sin(lat(visible)) - ...
                    sin(center_lat) .* cos(lat(visible)) .* cos(lon(visible) - center_lon)) ./ denom;
    end
end