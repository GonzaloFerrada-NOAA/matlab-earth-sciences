% function world : Add borders automatically in map 
% Valid arguments (order insensitive)
%     Map resolution  : String character. See below list of acceptable maps.
%     Color           : Line color of the map.
%     Line Width      : Line width of the map.
%     Projection      : If not specified: lat-lon
%                       If Lambert projection, argument should be array (size 2 or 4):
%                          [first_parallel,second_parallel,central_lat,central_lon];
%                       If Robinson, argument should be: 'Rob', 0
%                       If Orthogonal, argument should be: 'Ort', [center_lon, center_lat]
%                       If General perspective, argument should be: 'Pers', [center_lon, center_lat]
%
% Map resolutions available:
%     mc, mcoast          : Coastlines only. Medium resolution.
%     m0, mres0, mres     : Medium resolution boundaries level 0 (countries). [Default]
%     m1, mres1           : Medium resolution boundaries level 1 (states/provinces).
%     inm1                : Medium resolution interior boundaries level 1 (no coastlines).
%     hc, hcoast          : Coastlines only. High resolution.
%     h0, hres0, hires    : High resolution boundaries level 0 (countries).
%     h1, hres1           : High resolution boundaries level 0 (states/provinces).
%     inh1                : High resolution interior boundaries level 1 (no coastlines).
%     lakes               : High resolution lakes.
%     sh0                 : Super high resolution boundaries level 0 (countries).
%     sh1                 : Super high resolution boundaries level 1 (states/provinces).
%     usastates, usa1     : USA state boundaries.
%     usacounties, usa2   : USA county boundaries.
%     na1                 : World level 0 + North American countries level 1.
%     na2                 : World level 0 + USA country boundaries.
%     hstates             : World level 0 + Major countries level 1. High resolution.
%
% Author: Gonzalo A. Ferrada (gonzalo-ferrada@uiowa.edu)
% Version 1 - February 2021
% Change log:
% December 2024: Added support for Orthogonal projection.
% January 2025:  Added support for General Perspective Projection.
%
function add_borders(varargin)
    
% Defaults:
opts.color      = [1 1 1]*.3;
opts.lwidth     = 1;
opts.res        = 'm0';
opts.isrob      = false;
opts.isort      = false;
opts.ispers     = false;
opts.proj_stats = 0;

% Check if Robinson:
for i = 1:nargin
    if ischar(varargin{i}) & strcmpi(varargin{i},'Rob')
        opts.isrob   = true;
        opts.romlon  = varargin{i+1};
        varargin{i}  = [];
        varargin{i+1} = [];
    end
end

% Check if Orthogonal:
for i = 1:nargin
    if ischar(varargin{i}) & strcmpi(varargin{i},'Ort')
        opts.isort   = true;
        opts.ortparm = varargin{i+1};
        varargin{i}  = [];
        varargin{i+1} = [];
    end
end

% Check if General perspective projection:
for i = 1:nargin
    if ischar(varargin{i}) & (strcmpi(varargin{i},'Pers') | strcmpi(varargin{i},'pers'))
        opts.ispers   = true;
        opts.persparm = varargin{i+1};
        varargin{i}   = [];
        varargin{i+1} = [];
    end
end
        
% Check other arguments:
for i = 1:nargin
    % If string, then it is the map resolution or color
    if ischar(varargin{i}) & ~isempty(varargin{i})
        if numel(varargin{i}) == 1
            opts.color	= varargin{i};
        else
            opts.res = varargin{i};
        end
    elseif isnumeric(varargin{i}) & ~isempty(varargin{i})
        % Options for lambert projection, line width and/or color
        if numel(varargin{i}) == 1
            opts.lwidth      = varargin{i};
        elseif numel(varargin{i}) == 2 || numel(varargin{i}) == 4
            opts.proj_stats  = varargin{i};
        elseif numel(varargin{i}) == 3
            opts.color      = varargin{i};
        end
    end
end

% opts

% Load dataset:
load world.mat

% Get dataset to plot
switch opts.res
    % Medium resolution datasets:
    case {'mc','mcoast'};         ww = mc;
    case {'m0','mres','mres0'};   ww = m0;
    case {'m1','mres1'};          ww = m1;
    case {'inm1'};                ww = inm1;
    % High resolution datasets:
    case {'hc','hcoast'};         ww = hc;
    case {'h0','hires','hires0'}; ww = h0;
    case {'h1','hires1'};         ww = h1;
    case {'inh1'};                ww = inh1;
    case {'lakes'};               ww = lakes;
    % Super high resolution datasets:
    case {'sh0'};                 ww = sh0;
    case {'sh1'};                 ww = sh1;
    % USA datasets:
    case {'usastates','usa1'};    ww = usastates;
    case {'usacounties','usa2'};  ww = usacounties;
    % Major countries adm1:
    case {'na1','NA1','nonus'};   ww = nonus;
    case {'na2','NA2'};           ww = nonus;
    % Other datasets:
    case {'hstates'};             ww = hstates;
    otherwise 
        error('Invalid map resolution. To see list of available resolutions: help world')
end

% Plot
hold on
if opts.proj_stats == 0 & ~opts.isrob & ~opts.isort & ~opts.ispers % LAT-LON
    
    for i = 1:numel(ww)
        plot(ww{i}(:,1),ww{i}(:,2),'LineWidth',opts.lwidth,'Color',opts.color);
    end
    
    switch opts.res
    case {'na1','NA1'}
        for i = 1:numel(hstates)
            plot(hstates{i}(:,1),hstates{i}(:,2),'LineWidth',opts.lwidth,'Color',opts.color);
        end
    case {'na2','NA2'}
        for i = 1:numel(usacounties)
            plot(usacounties{i}(:,1),usacounties{i}(:,2),'LineWidth',opts.lwidth,'Color',opts.color);
        end
    end 
    
% ========================================================================================================
    
elseif numel(opts.proj_stats) > 1   % LAMBERT
    
    x_lim = get(gca,'XLim');
    y_lim = get(gca,'YLim');
    
    for i = 1:numel(ww)
        loni    = ww{i}(:,1);
        lati    = ww{i}(:,2);
        lati(loni==180 | loni==-180) = NaN;
        loni(loni==180 | loni==-180) = NaN;
        [loni,lati] = ll2lamb(opts.proj_stats,loni,lati);
        idx = abs(loni) > 5e4 | abs(lati) > 5e4;
        loni(idx) = NaN;
        lati(idx) = NaN;
        plot(loni,lati,'LineWidth',opts.lwidth,'Color',opts.color);
    end
    
    switch opts.res
    case {'na1','NA1'}
        for i = 1:numel(hstates)
            loni    = hstates{i}(:,1);
            lati    = hstates{i}(:,2);
            lati(loni==180 | loni==-180) = NaN;
            loni(loni==180 | loni==-180) = NaN;
            [loni,lati] = ll2lamb(opts.proj_stats,loni,lati);
            idx = abs(loni) > 5e4 | abs(lati) > 5e4;
            loni(idx) = NaN;
            lati(idx) = NaN;
            plot(loni,lati,'LineWidth',opts.lwidth,'Color',opts.color);
        end
    case {'na2','NA2'}
        for i = 1:numel(usastates)
            loni    = usastates{i}(:,1);
            lati    = usastates{i}(:,2);
            lati(loni==180 | loni==-180) = NaN;
            loni(loni==180 | loni==-180) = NaN;
            [loni,lati] = ll2lamb(opts.proj_stats,loni,lati);
            idx = abs(loni) > 5e4 | abs(lati) > 5e4;
            loni(idx) = NaN;
            lati(idx) = NaN;
            plot(loni,lati,'LineWidth',opts.lwidth,'Color',opts.color);
        end
        for i = 1:numel(usacounties)
            loni    = usacounties{i}(:,1);
            lati    = usacounties{i}(:,2);
            lati(loni==180 | loni==-180) = NaN;
            loni(loni==180 | loni==-180) = NaN;
            [loni,lati] = ll2lamb(opts.proj_stats,loni,lati);
            idx = abs(loni) > 5e4 | abs(lati) > 5e4;
            loni(idx) = NaN;
            lati(idx) = NaN;
            plot(loni,lati,'LineWidth',opts.lwidth,'Color',opts.color);
        end
    end 
    
    if sum(y_lim == x_lim) == 2
        % axis([4e5-3e6 4e5+3e6 4e5-2e6 4e5+2e6])
        % axis([4e5-3e6 4e5+3e6 4e5-2e6 4e5+2e6]./1e3)
        axis([-2700 2700 -2000 2000])
    else
        set(gca,'XLim',x_lim,'YLim',y_lim)
    end
    grid off
    
% ========================================================================================================

elseif opts.isrob       % ROBINSON
    
    for i = 1:numel(ww)
        lonr = ww{i}(:,1);
        latr = ww{i}(:,2);
        latr(lonr==180 | lonr==-180) = NaN;
        lonr(lonr==180 | lonr==-180) = NaN;
        [lonr,latr] = ll2rob(lonr,latr,opts.romlon);
        plot(lonr,latr,'LineWidth',opts.lwidth,'Color',opts.color)
    end
    
    switch opts.res
    case {'na1','NA1'}
        for i = 1:numel(hstates)
            [loni,lati] = ll2rob(hstates{i}(:,1),hstates{i}(:,2),opts.romlon);
            plot(loni,lati,'LineWidth',opts.lwidth,'Color',opts.color);
        end
    case {'na2','NA2'}
        for i = 1:numel(usastates)
            [loni,lati] = ll2rob(usastates{i}(:,1),usastates{i}(:,2),opts.romlon);
            plot(loni,lati,'LineWidth',opts.lwidth,'Color',opts.color);
        end
        for i = 1:numel(usacounties)
            [loni,lati] = ll2rob(usacounties{i}(:,1),usacounties{i}(:,2),opts.romlon);
            plot(loni,lati,'LineWidth',opts.lwidth,'Color',opts.color);
        end
    end
    
    grid off
    % Plot world boundary shape:
    lat = [-90:.1:90 90:-0.1:-90];
    lon = [ones(1,numel(lat)/2)*-180 ones(1,numel(lat)/2)*180];
    lon(end+1) = lon(1);lat(end+1) = lat(1);
    [lon,lat] = ll2rob(lon,lat);

    plot(lon,lat,'Color',opts.color,'LineWidth',opts.lwidth)
    % axis tight
    % set(gca,'XColor','none','YColor','none')
    % set(gca,'Box','off')
    
% ========================================================================================================

elseif opts.isort     % ORTHOGONAL
  R = 100; % it has to be the same value as in ll2ort
  for i = 1:numel(ww)
    [X,Y] = ll2ort(ww{i}(:,1), ww{i}(:,2), opts.ortparm);
    plot(X,Y,'Color',opts.color,'LineWidth',opts.lwidth)
    clear X Y
  end
  
  % Draw circle:
  theta = linspace(0, 2 * pi, 1000);
  X = R * cos(theta); % X-coordinates
  Y = R * sin(theta); % Y-coordinates
  plot(X,Y,'Color',opts.color,'LineWidth',opts.lwidth)
  
  set(gca,'XColor','none','YColor','none')
  
% ========================================================================================================

elseif opts.ispers    % GENERAL PERSPECTIVE PROJECTION
  
  R = 0; % for plotting of circle later
  for i = 1:numel(ww)
    
    if numel(opts.persparm) == 3
      [X,Y] = ll2pers(ww{i}(:,1), ww{i}(:,2), opts.persparm(1:2), opts.persparm(3));
    else
      [X,Y] = ll2pers(ww{i}(:,1), ww{i}(:,2), opts.persparm(1:2));
    end
    plot(X,Y,'Color',opts.color,'LineWidth',opts.lwidth)
    R = max([R X' Y'],[],'omitnan');
    clear X Y
  end

  % Draw circle:
  theta = linspace(0, 2 * pi, 1000);
  X = R * cos(theta); % X-coordinates
  Y = R * sin(theta); % Y-coordinates
  plot(X,Y,'Color',opts.color,'LineWidth',opts.lwidth)

  % set(gca,'XColor','none','YColor','none')
        
end

daspect([1 1 1])

end