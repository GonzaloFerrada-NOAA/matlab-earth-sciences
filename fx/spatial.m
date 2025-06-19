% SPATIAL creates plots of georeferenced data in a map. It supports 3 different
% projections (lat-lon, Robinson, Lambert, Orthogonal or General Perspective).
% Variable to plot should be 2-D.
%
% Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
% First developed: June 2019
% First available on GitHub: September 2024
% Lastest version: January 2025
%
% Required arguments:
%
% lon         : longitude in degrees (can be 1-D or 2-D).
% lat         : latitude in degrees (can be 1-D or 2-D).
% variable    : variable to plot (2-D).
%
% Optional Property Name arguments:
% 'Colormap'  : colormap to be used to plot. 'gmao2' is default.
% 'Colorbar'  : 'on' (default) or 'off'. Displays colorbar.
% 'Levels'    : variable levels/steps to plot. E.g.: [0:10:120].
% 'MapRes'    : 'na1' (default). See 'help world' for a complete list of options.
% 'MapWidth'  : line width of map boundaries (countries, states). Default is 0.5.
% 'MapColor'  : line color of map boundaries (countries, states). Default is dark gray.
% 'GeoTicks'  : 'on' (default) or 'off'. Displays axis ticks as georeferrenced.

% Required data and other scripts/functions:
% world.mat
% world.m
% surf2img.m
% hue.m
%
% Change log:
% January 2025
%   Added support for Orthogonal (Projection=3) and General Perspective (Projection=4) projections,
%   plus adding an additional parameter called 'Origin' for this two projections. 'Origin' can be
%   a vector of [center_lon, center_lat] or - for Perspective - [center_lon, center_lat, viewer_height].
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cbhandle, plothandle] = spatial(lon, lat, variable, varargin)
    
    p = inputParser;
    p.CaseSensitive = false;
    
    addRequired(p, 'lon');
    addRequired(p, 'lat');
    addRequired(p, 'variable');
    addOptional(p, 'Projection', 0); % 0: lat-lon, 1: Robinson, 2: Lambert, 3: Orthogonal
    
    addParameter(p,     'Type','surf')
    addParameter(p, 'Colormap', hue('gmao2',64))
    addParameter(p, 'Colorbar', 'on')
    addParameter(p,   'Levels', [])
    addParameter(p,   'MapRes', 'na1')
    addParameter(p, 'MapWidth', 0.5)
    addParameter(p, 'MapColor', [1 1 1] * 0.25)
    addParameter(p, 'GeoTicks', 'on')
    addParameter(p, 'Origin', [0 0])  % [center_lon, center_lat] for Orthogonal and Perspective projections
    
    p.KeepUnmatched = false;

    parse(p,lon,lat,variable,varargin{:})

    opts = p.Results;
    
    % ====================================================================================
    
    % Check for errors in input arguments:
    [Nx Ny Nz Nt] = size(variable);
    if (Nz > 1); error('Input variable to plot is 3-D. It should be 2-D');end
    if (Nt > 1); error('Input variable to plot is 4-D. It should be 2-D');end

    % Fix longitude/latitude in case they are 1-D:
    if (size(lon,1) == 1 || size(lon,2) == 1)
        [lon,lat] = ndgrid(lon,lat);
    end
    
    if (size(lon) ~= size(variable)); error('The size of the input coordinates (lon, lat) do not match the variable''s');end
    
    % Determine projection:
    islatlon      = opts.Projection == 0;
    isrobinson    = opts.Projection == 1;
    islambert     = numel(opts.Projection) > 1 | (numel(opts.Projection) == 1 & opts.Projection == 2);
    isorthogonal  = opts.Projection == 3;
    isperspective = opts.Projection == 4;
    
        
    % Fix lat and lon in case 'Type' = 'rsurf':
    if strcmp(opts.Type,'rsurf') & ~islambert 
        [lon,lat] = surf2img(lon,lat);
    end
    
    % Reproject data if Projection ~= 0
    % Robinson (Projection = 1)
    if isrobinson
        [lon,lat] = ll2rob(lon,lat);
    end
    
    % Lambert (Projection = 2)
    if islambert
        % Determine automatic center lon and center lat in case they are not provided
        if numel(opts.Projection) == 1
            opts.Projection = [mean(lat(:)) mean(lon(:))];
        end
    
        ax_auxi   = axes;
        % pcolor(lon,lat,nan(size(lon)))
        surface(lon,lat,zeros(size(lon)),nan(size(lon)))
        lat_ticks = get(gca,'YTick'); if numel(lat_ticks) > 9; lat_ticks = lat_ticks(1:2:end); end
        lon_ticks = get(gca,'XTick'); if numel(lon_ticks) > 9; lon_ticks = lon_ticks(1:2:end); end
        delete(ax_auxi)
        lon_orig = lon; 
        lat_orig = lat;
        [lon,lat] = ll2lamb(opts.Projection,lon,lat);
        lon = real(lon);
        lat = real(lat);
        
        if strcmp(opts.Type,'rsurf')
            [lon,lat] = surf2img(lon,lat);
        end
    end
    
    % Orthogonal projection (Projection = 3)
    if isorthogonal
      
      [lon, lat] = ll2ort(lon, lat, opts.Origin);
      
    end
    
    if isperspective
      
      if numel(opts.Origin) == 2
        [lon, lat] = ll2pers(lon, lat, opts.Origin);
      elseif numel(opts.Origin) == 3
        [lon, lat] = ll2pers(lon, lat, opts.Origin(1:2), opts.Origin(3));
      end
      
    end
    
    % Getting custom variable levels to display:
    if ~( isempty(opts.Levels) )
      
        [variable, cbartick, cbarticklabel] = data2levels( variable, opts.Levels );
        
    end
    
    % Determine if data to plot (variable) has NaNs:
    hasnans = sum(isnan(variable(:))) > 0;
    
    % Ready to plot data:
    switch opts.Type
    case {'surf', 'rsurf'}
        
        % Make surface:
        h = surface(lon,lat,zeros(size(lon)),variable,'FaceColor','texturemap','EdgeColor','none', ... 
                    'FaceAlpha','texturemap','AlphaData',~isnan(variable));
        view(2)
        axis([min(lon(:)) max(lon(:)) min(lat(:)) max(lat(:))])
        
    case {'im', 'imsc'}
        
        % Display as image:
        h = imagesc(lon(:,1),lat(1,:),variable','AlphaData',~isnan(variable'));
        set(gca,'YDir','normal')
        
    otherwise
        
        error([opts.Type ' is not a valid option for the ''Type'' property'])
        
    end
    
    
    hold on
    
    
    % Add coastlines, country or states, and define axis limits:
    if ~strcmp(opts.MapColor,'none')
    
        if islatlon                         % lat-lon plot
        
            xl = get(gca,'XLim'); yl = get(gca,'YLim');
            world(opts.MapRes,opts.MapWidth,opts.MapColor)
            set(gca,'XLim',xl,'YLim',yl); clear xl yl
        
        elseif isrobinson                    % Robinson
        
            world(opts.MapRes,opts.MapWidth,opts.MapColor,'Rob',0)
            
        elseif isorthogonal
          
            world(opts.MapRes, opts.MapWidth, opts.MapColor, 'Ort', opts.Origin)
            
        elseif isperspective
          
            world(opts.MapRes, opts.MapWidth, opts.MapColor, 'Pers', opts.Origin)
        
        elseif numel(opts.Projection) > 1    % Lambert
            
            world(opts.MapRes,opts.MapWidth,opts.MapColor,opts.Projection)
        
        end
    end
    
    set(gca,'Colormap',opts.Colormap)
    
    % Add colorbar:
    switch opts.Colorbar
    case 'on'
        cb = colorbar('TickDirection','both');
        
        if ~(isempty(opts.Levels))
            set(gca,'CLim',[cbartick(1) cbartick(end)])
            set(cb,'YTick',cbartick,'YTickLabel',cbarticklabel)
        end
        
    otherwise
        cb = [];
    end
    
    % Figure properties:
    set(gca,'Layer','top','Box','on')
    set(gca,'DataAspectRatio',[1 1 1])
    set(gcf,'InvertHardcopy', 'off')
    
    
    % Add geoticks:
    switch opts.GeoTicks
    case 'on'
        if opts.Projection == 0             % lat-lon
            
            ticks2geo;
    
        elseif opts.Projection == 1         % Robinson
        
            robgeoticks;
        
        elseif numel(opts.Projection) > 1   % Lambert
            
            axl = abs(axis);
            if max(axl) > 1e4
                axis([-2700 2700 -2000 2000])
            end
        
            lambgeoticks(opts.Projection,mean(diff(lon_ticks)),mean(diff(lat_ticks)))
        
        end
    end
    
    

    % Special settings for Robinson:
    if isrobinson
        axis tight
        set(gca,'XColor','none','YColor','none')
        set(gca,'Box','off')
    end
    
    % Special settings for Lambert
    if islambert
      
      % If it is global data being plotted in Lambert projection
      % the plot axis go exponentially high and nothing is visible
      % at first glance without the user sets the axis themselves.
      % This is to avoid that:
      dlon = max(lon(:)) - min(lon(:));
      dlat = max(lat(:)) - min(lat(:));
      isglob = dlon > 270 | dlat > 120;
      
      if isglob 
        set(gca,'XLim',[-1 1] * 2700) 
        set(gca,'YLim',[-1 1] * 1800)
      end
      
    end
    
    % Output arguments:
    if nargout
         cbhandle   = cb;
         plothandle = h;
    end

end % function


function [dataout, cbarticks, clabels] = data2levels(datain, levels)
  
  % Prepare data:
  dataout   = nan(size(datain));
  cbarticks = 1:numel(levels);
  clabels   = num2str(levels');
  
  % Data values < levels(1):
  dataout( datain < levels(1) )   = 1;
  
  for i = 1:numel(levels) - 1
    
    idx = datain >= levels(i) & datain < levels(i + 1);
    dataout( idx ) = i;
    
  end
  
  % Data values >= levels(end):
  dataout( datain >= levels(end)) = numel(levels);
  
end