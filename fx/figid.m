% figure_id(str,varargin)
% Add letters for multi panel figures
% Author: Gonzalo A. Ferrada (gonzalo-ferrada@uiowa.edu)
% July 2019
%
% Position    = innerleft or inleft (default)
%               innerright or inright
%               outerleft or outleft
%               outerright or outright
%               bottomleft
%               bottomright
% Background  = background color, default is no background
% FontSize    = integer, default is 15   
% FontName    = font name, default is monospaced
% Color       = font color, default is black
% FontWeight  = font weight: normal (default) or bold
% EdgeColor   = edge of text box, default is no border
%          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change log:
%
% v1.1 (2020-06-21):
% Adding option for location bottomleft and bottomright (always inside plot).
%
% v1.2 (2020-09-28):
% Adding output: h for modifications
% 

function h = figid(str, varargin)

p = inputParser;

addRequired(p,'str');

% Defaults:
addParameter(p, 'Location',     'outleft')
addParameter(p, 'FontSize',            10)
addParameter(p, 'Background',      'none')
addParameter(p, 'FontName',  'Monospaced')
addParameter(p, 'Color',    [1 1 1] * .35)
addParameter(p, 'FontWeight',    'normal')
addParameter(p, 'EdgeColor',       'none')
addParameter(p, 'Box',              false)

% p.KeepUnmatched = true;

parse(p,str,varargin{:})

opt.location     = p.Results.Location;
opt.fontsize     = p.Results.FontSize;
opt.background   = p.Results.Background;
opt.fontname     = p.Results.FontName;
opt.color        = p.Results.Color;
opt.fontweight   = p.Results.FontWeight;
opt.edgecolor    = p.Results.EdgeColor;
opt.box          = p.Results.Box;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hold on

native_units = get(gca,'units');
set(gca,'Units','normalized');

x_lim = get(gca,'XLim');
y_lim = get(gca,'YLim');

% Offsets:
ratio = diff(y_lim)/diff(x_lim);
offy  = .015; % fitted on corner
offx  = offy * ratio;

% Get positions:
switch opt.location
case {'inleft', 'innerleft'}
  VA = 'top';
  HA = 'left';
  X  = 0.025 + offx;
  Y  = 1.0 - offy;
  
case {'inright', 'innerright'}
  VA  = 'top';
  HA  = 'right';
  X   = 1.0 - offx; 
  Y   = 1.0 - offy; 
  
case {'outerleft', 'outleft'}
  VA  = 'bottom';
  HA  = 'left';
  X   = 0.0 + offx; 
  Y   = 1.0 + offy;
  
case {'outerright', 'outright'}
  VA  = 'bottom';
  HA  = 'right';
  X   = 1.0 - offx; 
  Y   = 1.0 + offy; 
  
case 'bottomleft'
  VA  = 'bottom';
  HA  = 'left';
  X   = 0.0 - offx; 
  Y   = 0.0 + offy;

case 'bottomright'
  VA  = 'bottom';
  HA  = 'right';
  X   = 1.0 - offx; 
  Y   = 0.0 + offy;

otherwise
  error(['The location option provided (' opt.location ') is not available.'])
end

if opt.box
  if strcmpi(opt.background, 'none')
    opt.background = 'w';
  end
  if strcmpi(opt.edgecolor, 'none')
    opt.edgecolor = [1 1 1] * .15;
  end
end
  

    
h = text(double(X),double(Y),str,'Units','normalized', ...
                  'FontSize',opt.fontsize, ...
                  'BackgroundColor',opt.background, ...
                  'Margin',2, ...
                  'FontName',opt.fontname, ...
                  'Color',opt.color, ...
                  'VerticalAlignment',VA, ...
                  'HorizontalAlignment',HA, ...
                  'EdgeColor',opt.edgecolor);
                  
% Switch back to plot's native units:
set(gca,'Units',native_units);

end
