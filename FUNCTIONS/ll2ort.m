function [X, Y] = ll2ort(lon, lat, param)
  % Inputs:
  % londeg = longitude in degrees.
  % latdeg = latitude in degrees.
  % para   = [center_longitude, center_latitude]
  % 
  % Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
  % December 2024
  
  R = 100;
  
  X = R .* cosd(lat) .* sind(lon - param(1));
  Y = R .* (cosd(param(2)) .* sind(lat) - sind(param(2)) .* cosd(lat) .* cosd(lon - param(1)));
  
  % Remove points outside Earth's side/hemisphere being plotted:
  cosc  = sind(param(2)) .* sind(lat) + cosd(param(2)) .* cosd(lat) .* cosd(lon - param(1));
  I     = acos(cosc) < -pi/2 | acos(cosc) > pi/2;
  X(I)  = NaN;
  Y(I)  = NaN;
  
end