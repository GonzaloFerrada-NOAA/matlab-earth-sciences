% Function to read UFS' model NetCDF variable and transform the
% longitude coordinates from 0 to 360 deg to -180 to +180 deg
% Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
% August 2024

% Add support for ocean files: September 2024 ( did not work)

function out = ufs(file,varname,istart,icount)
  
  % Default names in atmos UFS output:
  lonvar = 'lon';
  latvar = 'lat';
  
  % % Check if those exist, if not it is an ocean file:
  % if ~varexist(file, lonvar)
  %   lonvar = 'geolon';
  %   latvar = 'geolat';
  % end
  
  % Read lon and lat first. This is necessary to convert
  % longitudes from 0 to 360 to -180 to 180:
  lon = ncread(file, lonvar, [1 1], [Inf 1]);  % 1-D
  lat = ncread(file, latvar, [1 1], [1 Inf]);  % 1-D
  
  % Change longitude from 0-360 to -180-+180
  lon = mod((lon + 180), 360) - 180;
  idx = lon < 0;
  lon = [lon(idx);lon(~idx)];  
  
  % Convert both coordinates to 2-D:
  [lon,lat] = ndgrid(lon,lat);
  
  % Read desired variable:
  % Output:
  switch varname
  case 'lon'
    out = lon;
  case 'lat'
    out = lat;
  otherwise
    ~exist('istart','var')
    ~exist('icount','var')
    if ~exist('istart','var') & ~exist('icount','var')
      aux = ncread(file, varname);
    else
      aux = ncread(file, varname, istart, icount);
    end
    out = [aux(idx,:,:,:); aux(~idx,:,:,:)];
  end

end


function out = varexist(file, varname)
  finfo = ncinfo(file);
  fvars = {finfo.Variables.Name};
  out   = ismember('aod550', fvars);
end