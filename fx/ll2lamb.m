function [x,y] = ll2lamb(ps, lon_degrees, lat_degrees)
% ll2lamb: Convert lon/lat (deg) to Lambert Conformal Conic (LCC) x/y.
%
% Usage:
%   [x,y] = ll2lamb(ps, lon_degrees, lat_degrees)
%
% Inputs:
%   ps            Projection specs:
%                   - 4 elements: [lat1 lat2 center_lat center_lon]
%                   - 2 elements: [center_lat center_lon]
%                     (assumes a tangent cone: lat1 = lat2 = center_lat)
%   lon_degrees   Longitudes in decimal degrees (vector or array)
%   lat_degrees   Latitudes  in decimal degrees (vector or array)
%
% Outputs:
%   x, y          Projected coordinates (arbitrary distance units)
%
% Notes:
%   - Spherical formulas (Snyder). Scale is arbitrary; suitable for plotting.
%   - If lon_degrees and lat_degrees are 1-D vectors of different lengths,
%     they are expanded to a 2-D grid using ndgrid (like ll2rob).
%
% Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
% February 2026

% --- Parse projection specs ---
if numel(ps) == 4
    lat1 = ps(1);
    lat2 = ps(2);
    lat0 = ps(3);
    lon0 = ps(4);
elseif numel(ps) == 2
    lat0 = ps(1);
    lon0 = ps(2);
    lat1 = lat0;
    lat2 = lat0; % tangent case (this is OK; no tiny offset needed)
else
    error('ps must have 2 elements [center_lat center_lon] or 4 elements [lat1 lat2 center_lat center_lon].');
end

% % Match ll2rob behavior: if inputs are 1-D and lengths mismatch, expand.
% if numel(lon_degrees) ~= numel(lat_degrees) && (isvector(lon_degrees) && isvector(lat_degrees))
%     [lon_degrees, lat_degrees] = ndgrid(lon_degrees, lat_degrees);
% end

% --- Constants ---
% R = 100; % arbitrary (useful for plotting)
R = 6377.39715500000;

% --- Convert to radians ---
phi  = deg2rad(lat_degrees);

% Wrap lon around lon0 so (lon-lon0) is in [-180,180)
dlon = mod(lon_degrees - lon0 + 180, 360) - 180;   % degrees
lam  = deg2rad(lon0 + dlon);

lam0 = deg2rad(lon0);
phi0 = deg2rad(lat0);
phi1 = deg2rad(lat1);
phi2 = deg2rad(lat2);

% --- Snyder LCC (sphere) ---
% n parameter
if abs(phi1 - phi2) < 1e-12
    n = sin(phi1); % tangent case
else
    n = log(cos(phi1)./cos(phi2)) ./ ...
        log(tan(pi/4 + phi2/2)./tan(pi/4 + phi1/2));
end

% Guard: n ~ 0 can happen for near-equatorial standard parallels
if abs(n) < 1e-14
    error('Invalid projection specs: n is ~0. Choose standard parallels away from 0 deg.');
end

F    = (cos(phi1) .* (tan(pi/4 + phi1/2)).^n) ./ n;
rho  = R .* F ./ (tan(pi/4 + phi/2)).^n;
rho0 = R .* F ./ (tan(pi/4 + phi0/2)).^n;

theta = n .* (lam - lam0);

x = rho  .* sin(theta);
y = rho0 - rho .* cos(theta);

end