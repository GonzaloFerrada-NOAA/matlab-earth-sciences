% Pack data to write into a netcdf file.
%
% [packed_data, scale_factor, add_offset] = packdata(data)
%
% Input data can be either class, but numeric.
% Output packed_data is the data as int16 (NC_SHORT)
%
%     ncccreate('mynetcdf.nc', 'variable_name', ... )
%     ncwrite('mynetcdf.nc', 'variable_name', packed_data)
%     ncwriteatt('mynetcdf.nc', 'scale_factor', scale_factor)
%     ...
% 
%
% Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
% January 2025

function [packed_data, scale_factor, add_offset] = packdata(data)
  
    % Determine the range of the data
    data_min = min(data(:));
    data_max = max(data(:));
    
    % Define the integer range for 'short' (int16)
    int_min = -2 ^ 15; % -32768
    int_max = 2 ^ 15 - 1; % 32767
    
    % Compute scale factor and add offset
    scale_factor = (data_min - data_max) / (int_max - int_min);
    add_offset = data_min + (int_min * scale_factor);
    
    scale_factor = single(scale_factor);
    add_offset   = single(add_offset);
    
    % Pack the data
    packed_data = round((data - add_offset) / scale_factor);
    packed_data = min(max(packed_data, int_min), int_max); % Clip to range
    packed_data = int16(packed_data); % Convert to int16
end


% function unpacked_data = unpackdata(packed_data, scale_factor, add_offset)
%     % Convert packed data back to original scale
%     unpacked_data = double(packed_data) * scale_factor + add_offset;
% end