function garea = eartharea(lon, lat)

	sz = size(lon);
	if isvector(lon) && isvector(lat)

		latIsDescending = numel(lat) > 1 && lat(2) < lat(1);
		if latIsDescending
			latCalc = flip(lat);
		else
			latCalc = lat;
		end

		difx = diff(lon);
		isUniform = all(difx(:) == difx(1));
		% if isUniform
			dlon = abs(mean(difx));
			dlat = mean(diff(latCalc));
		% else
			% error('lon and lat should be uniform.')
		% end

	elseif ismatrix(lon) && all(sz > 1)

		error('lon and lat should be 1-D.')

	else
		error('lon and lat should be 1-D.')
	end


	R = 6371000; % Earth's radius in meters

	% Build the area grid using ascending latitude, then restore input order.
	[lonGrid, latGrid] = ndgrid(lon, latCalc);

	% Convert grid spacing to radians
	dlonRad = deg2rad(dlon);

	% Latitude edges (half-cell shift)
	lat1 = deg2rad(latGrid - dlat/2); % southern edge
	lat2 = deg2rad(latGrid + dlat/2); % northern edge

	% Calculate area (element-wise)
	gareaCalc = R^2 * dlonRad .* (sin(lat2) - sin(lat1));

	if latIsDescending
		garea = fliplr(gareaCalc);
	else
		garea = gareaCalc;
	end

end
