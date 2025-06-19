function garea = eartharea(lon, lat)
	
	sz = size(lon);
	if isvector(lon)
		
			difx 					= diff(lon);
			isUniform 		= all(difx(:) == difx(1));
			% if isUniform
				dlon = mean(difx);
				dlat = mean(diff(lat));
			% else
				% error('lon and lat should be uniform.')
			% end
			
	elseif ismatrix(lon) && all(sz > 1)
	    
		error('lon and lat should be 1-D.')
			
	else
	    error('lon and lat should be 1-D.')
	end
	
	
	R 			= 6371000; % Earth's radius in meters
	
	% now that we have calculated dlon and dlat, we can convert it to 2-D:
	[lon, lat] = ndgrid(lon, lat);

	% Convert grid spacing to radians
	dlat_rad = deg2rad(dlat);
	dlon_rad = deg2rad(dlon);
	
	% Latitude edges (half-cell shift)
	lat1 = deg2rad(lat - dlat/2); % southern edge
	lat2 = deg2rad(lat + dlat/2); % northern edge

	% Calculate area (element-wise)
	garea  = R^2 * dlon_rad .* (sin(lat2) - sin(lat1)); % same size as lat/lon
	
end