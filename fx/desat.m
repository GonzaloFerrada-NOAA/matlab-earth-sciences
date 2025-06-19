function out = desat(cmap, R)
	
	% DESAT desaturates a certain color or colormap by a ratio R (between 0 and 1),
	% where 0 is completely desaturated (grayscale), while 1 is the original saturation
	% data (i.e., output is the same as input).
	%
	% Usage:
	%
	% desaturated_colormap = DESAT(colormap_in, ...)
	% desaturated_colormap = DESAT(colormap_in, Ratio)
	%
	% Ratio is optional. Default is 0.8.
	%
	% Author: Gonzalo A. Ferrada (Gonzalo.Ferrada@noaa.gov)
	% March 2025
  
	if ~exist('R', 'var')
		R = 0.8;
	end
  
  if size(cmap,3) == 1 % color or colormap
	
  	cmap_hsv 				= rgb2hsv(cmap); 					% Convert to HSV
  	cmap_hsv(:,2) 	= cmap_hsv(:,2) * R; 		  % Reduce saturation (0 = grayscale, 1 = full color)
  	out 						= hsv2rgb(cmap_hsv); 			% Convert back to RGB
    
  elseif size(cmap,3) == 3 % image
    
    img_hsv         = rgb2hsv(cmap);          % Convert to HSV
    img_hsv(:,:,2)  = img_hsv(:,:,2) * R;     % Reduce saturation (adjust factor as needed)
    out             = hsv2rgb(img_hsv);
    
  else 
    
    error('Could not identify whether cmap is a color, colormap or image.')
    
  end
	
end