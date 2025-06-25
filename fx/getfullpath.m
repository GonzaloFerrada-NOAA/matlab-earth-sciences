function fullPath = findfile(Pattern)
	% Get full path of a file or directory.
	% Usage:
	% 				fullPath = findfile(Pattern)
	% Argument:
	%		Pattern : Pattern to find. 
	%             E.g.: Pattern = 'path/to/dir/file_*.txt';
	% 
	% Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
	% June 2025
	
	d = dir(Pattern);
	
	if isempty(d)
	    error('No files matched "%s".', Pattern);
	end
	
  % Grab the first match’s full path:
	fullPath = fullfile(d(1).folder, d(1).name);
	
	% if ~exist(fullPath, 'file')
	%     error('File not found: %s', fullPath);
	% end
end