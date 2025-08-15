function string_rgb = ctext(str, c)
	% Usage:
	% colored_text_string = ctext(str, color)
	%
	% Arguments:
	% 	str		: String
	% 	color	: Color to apply to String. Can be a 3 element vector or a char of size 1 ('r','b','k', etc.)
	
	if ischar(c)
		switch c
		    case 'r'
		        col = [1 0 0];
		    case 'g'
		        col = [0 1 0];
		    case 'b'
		        col = [0 0 1];
		    case 'c'
		        col = [0 1 1];
		    case 'm'
		        col = [1 0 1];
		    case 'y'
		        col = [1 1 0];
		    case 'k'
		        col = [0 0 0];
		    case 'w'
		        col = [1 1 1];
		    otherwise
		        error('Unknown color code')
		end
		
		clear c 
		c = col;
	end
	
	% c = c * 255;
	
	string_rgb = ['\color[rgb]{' sprintf('%5.3f, %5.3f, %5.3f', c) '}' char(str)];
	
end