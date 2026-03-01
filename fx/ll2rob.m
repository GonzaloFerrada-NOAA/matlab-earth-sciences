function [x,y] = ll2rob(lon_deg, lat_deg, center_lon)
%LL2ROB  Convert lon/lat (deg) to Robinson projection x/y (no toolbox).
%
%   [x,y] = LL2ROB(lon_deg, lat_deg)
%   [x,y] = LL2ROB(lon_deg, lat_deg, center_lon)
%
% Inputs
%   lon_deg     Longitudes in decimal degrees. Vector or array.
%   lat_deg     Latitudes  in decimal degrees. Vector or array.
%   center_lon  (optional) Central meridian in degrees. Default = 0.
%              This shifts the map seam to be opposite center_lon and helps
%              keep features continuous near the dateline (or any chosen seam).
%
% Outputs
%   x, y        Robinson projected coordinates (arbitrary distance units).
%
% Behavior / Notes
%   - Uses Robinson tabulated coefficients (Snyder), interpolated with PCHIP.
%   - Longitudes are wrapped relative to center_lon so that (lon-center_lon)
%     stays within [-180, +180] degrees. IMPORTANT: +180 is preserved as +180
%     (not folded to -180). This is needed to draw the Robinson "frame" when
%     the boundary is defined at lon = ±180.
%   - For polyline inputs (lon/lat vectors of same size), the function
%     automatically inserts NaN breaks where a seam crossing would otherwise
%     cause MATLAB to draw a long connector line across the map.
%   - For gridded inputs (2-D arrays, or when lon/lat are expanded via NDGRID),
%     no NaN breaks are inserted.
%
% Example
%   % Global Robinson, seam at 180 (centered on dateline):
%   [x,y] = ll2rob(coast_lon, coast_lat, 180);
%   plot(x,y,'k-'); axis equal
%
% Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
% Updated: March 2026

% --- Defaults ---
if nargin < 3 || isempty(center_lon)
    center_lon = 0;
end

% --- Robinson table: [latitude(deg), Xcoef, Ycoef] ---
Rob = [-90.0000    0.5322   -1.0000
       -85.0000    0.5722   -0.9761
       -80.0000    0.6213   -0.9394
       -75.0000    0.6732   -0.8936
       -70.0000    0.7186   -0.8435
       -65.0000    0.7597   -0.7903
       -60.0000    0.7986   -0.7346
       -55.0000    0.8350   -0.6769
       -50.0000    0.8679   -0.6176
       -45.0000    0.8962   -0.5571
       -40.0000    0.9216   -0.4958
       -35.0000    0.9427   -0.4340
       -30.0000    0.9600   -0.3720
       -25.0000    0.9730   -0.3100
       -20.0000    0.9822   -0.2480
       -15.0000    0.9900   -0.1860
       -10.0000    0.9954   -0.1240
        -5.0000    0.9986   -0.0620
         0.0000    1.0000    0.0000
         5.0000    0.9986    0.0620
        10.0000    0.9954    0.1240
        15.0000    0.9900    0.1860
        20.0000    0.9822    0.2480
        25.0000    0.9730    0.3100
        30.0000    0.9600    0.3720
        35.0000    0.9427    0.4340
        40.0000    0.9216    0.4958
        45.0000    0.8962    0.5571
        50.0000    0.8679    0.6176
        55.0000    0.8350    0.6769
        60.0000    0.7986    0.7346
        65.0000    0.7597    0.7903
        70.0000    0.7186    0.8435
        75.0000    0.6732    0.8936
        80.0000    0.6213    0.9394
        85.0000    0.5722    0.9761
        90.0000    0.5322    1.0000];

% Scale (kept consistent with your original usage; arbitrary plotting units)
R = 63.71;

% --- Expand 1-D lon/lat vectors to 2-D grid if needed (for gridded data) ---
did_expand = false;
if isvector(lon_deg) && isvector(lat_deg) && (numel(lon_deg) ~= numel(lat_deg))
    [lon_deg, lat_deg] = ndgrid(lon_deg, lat_deg);
    did_expand = true;
end


% --- Wrap longitude relative to center_lon, keeping +180 as +180 ---
d = lon_deg - center_lon;                           % degrees (unwrapped)
dlon = mod(d + 180, 360) - 180;                     % [-180, 180)
dlon(dlon == -180 & d > 0) = 180;                   % preserve +180

% --- For polyline vectors: break segments across the seam to avoid long connectors ---
is_polyline = isvector(lon_deg) && isvector(lat_deg) && isequal(size(lon_deg), size(lat_deg)) && ~did_expand;
if is_polyline
    % Work only on finite runs (respect existing NaNs)
    finite = isfinite(dlon) & isfinite(lat_deg);
    if any(finite)
        j = false(size(dlon));
        k = find(finite);
        dk = abs(diff(dlon(k)));
        j(k(2:end)) = dk > 180;     % seam jump inside a continuous run
        lon_deg(j) = NaN;
        lat_deg(j) = NaN;
        dlon(j) = NaN;
    end
end

if center_lon ~= 0
    % Remove points at 180 meridian:
    IX = (lon_deg >= 180 - 1e-5 | lon_deg <= -180 + 1e-5) & ((lat_deg > 62 & lat_deg < 74) | lat_deg < -84);
    lat_deg(IX) = NaN; lon_deg(IX) = NaN;
end

% --- Interpolate Robinson coefficients as a function of latitude ---
Xc = interp1(Rob(:,1), Rob(:,2), lat_deg, 'pchip');
Yc = interp1(Rob(:,1), Rob(:,3), lat_deg, 'pchip');

% --- Robinson forward equations (spherical) ---
x = 0.8487 * R .* Xc .* deg2rad(dlon);
y = 1.3523 * R .* Yc;

end