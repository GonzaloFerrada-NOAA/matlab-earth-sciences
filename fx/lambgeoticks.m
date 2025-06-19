function grid_handle = lambgeoticks(proj_specs,interval_lon,interval_lat)
%
% function grid_handle = lambgeoticks(proj_specs,interval_lon,interval_lat)
% Removes current figure ticks and adds geo-coordinates and grid lines in
% Lambert transformation.
% Required: ll2lamb and Lambert.
%
% Usage:
% proj_specs   :  [TRUELAT1,TRUELAT2,CEN_LAT,CEN_LON] == [first_parallel,second_parallel,central_lat,central_lon];
% interval_lon :  interval (degrees) for longitude intervals.
% interval_lat :  (optional) interval (degrees) for longitude intervals.
%                 If not specified, it will use same interval as in interval_lon.
%
% Examples:
%     lambgeoticks([38.5 39 37 -97.5],10,20)
%     lambgeoticks([38.5 -97.5],25)
%

if ~exist('proj_specs','var')
    error(' Projection specifications (proj_specs) is missing. See usage.')
elseif ~exist('interval_lon','var')
    error(' Interval for ticks (interval_lon) is missing. See usage.')
end

if ~exist('interval_lat','var')
    interval_lat = interval_lon; 
end

% Read input:
lon_ticks   = -180:interval_lon:180;
lat_ticks   = -80:interval_lat:80;

% Grid line specifications:
grid_alpha = 0.1;
grid_style = '-';

% Get lambert projection:
if numel(proj_specs) == 2
    proj_specs = [proj_specs(1) proj_specs(1) proj_specs(1) proj_specs(2)];
end

% Fix in case origin latitudes are the same:
if proj_specs(1) == proj_specs(2); 
    proj_specs(1) = proj_specs(1) + 1e-5; 
    proj_specs(2) = proj_specs(2) - 1e-5; 
end

% Flag for hemisphere:
northern_hemisphere = proj_specs(3) > 0;
southern_hemisphere = proj_specs(3) < 0;

if southern_hemisphere
    proj_specs = [-proj_specs(1) -proj_specs(2) -proj_specs(3) proj_specs(4)];
end

% Get Lambert projection:
% lamb = Lambert([proj_specs(1),proj_specs(2)],proj_specs(3),proj_specs(4),400000,400000,6377397.15500000,299.152815351328);
% lamb = Lambert([proj_specs(1),proj_specs(2)],proj_specs(3),proj_specs(4),400,400,6377.39715500000,299.152815351328);
lamb = Lambert([proj_specs(1),proj_specs(2)],proj_specs(3),proj_specs(4),0,0,6377.39715500000,299.152815351328);

% Get current axes limits:
x_lim   = get(gca,'XLim');
y_lim   = get(gca,'YLim');

[lat_lim,lon_lim] = lamb.cartesian2geographic(x_lim,y_lim);

if southern_hemisphere
    proj_specs = [-proj_specs(1) -proj_specs(2) -proj_specs(3) proj_specs(4)];
    % lamb = Lambert([proj_specs(1),proj_specs(2)],proj_specs(3),proj_specs(4),400000,400000,6377397.15500000,299.152815351328);
    % lamb = Lambert([proj_specs(1),proj_specs(2)],proj_specs(3),proj_specs(4),400,400,6377.39715500000,299.152815351328);
    lamb = Lambert([proj_specs(1),proj_specs(2)],proj_specs(3),proj_specs(4),0,0,6377.39715500000,299.152815351328);
    lat_lim = -lat_lim;
end

%%%
% =====================================================================================
% Plot Latitude lines:
for i = 1:numel(lat_ticks)
    aux_lat    = lat_ticks(i);
    lat_tick_x = linspace(-200,200,4000);
    lat_tick_y = ones(size(lat_tick_x)) .* aux_lat;

    [ticklat, ticklon] = ll2lamb(proj_specs,lat_tick_x,lat_tick_y);

    % filter out for correct tick position:
    idx_out = ticklon < y_lim(1) | ticklon > y_lim(2) | ticklat < x_lim(1) | ticklat > x_lim(2);
    ticklat(idx_out) = NaN;
    ticklon(idx_out) = NaN;
    
    idx     = ~isnan(ticklon);
    ticklon = ticklon(idx);
    ticklat = ticklat(idx);

    if sum(idx) >= 1
        
        % Plot grid line:
        ll = plot(ticklat,ticklon,grid_style,'LineWidth',.5);
        ll.Color = [.15,.15,.15,grid_alpha];
        
        % Determine if current grid line crosses X-Axis:
        dist_axis  = ticklat(1) - x_lim(1);
        crosses_ax = abs(dist_axis) < diff(x_lim)*0.01;
        
        if crosses_ax
            ticks_y(i)  = ticklon(1);
            if aux_lat < 0
                degr = [num2str(abs(aux_lat)) char(176) 'S'];
            elseif aux_lat == 0
                degr = [num2str(abs(aux_lat)) char(176)];
            elseif aux_lat > 0
                degr = [num2str(abs(aux_lat)) char(176) 'N'];
            end
            tlabs_y{i}  = degr;
        end
    end
end

idx          = ticks_y==0;
ticks_y(idx) = [];
tlabs_y(idx) = [];

% =====================================================================================
% Plot Longitude lines:
for i = 1:numel(lon_ticks)
    aux_lon    = lon_ticks(i);
    lon_tick_y = linspace(-80,80,1e4);
    lon_tick_x = ones(size(lon_tick_y)) * aux_lon;
    
    [ticklat, ticklon] = ll2lamb(proj_specs,lon_tick_x,lon_tick_y);
    ticklat = real(ticklat);
    ticklon = real(ticklon);

    % filter out for correct tick position:
    idx_out = ticklon < y_lim(1) | ticklon > y_lim(2) | ticklat < x_lim(1) | ticklat > x_lim(2);
    ticklat(idx_out) = NaN;
    ticklon(idx_out) = NaN;
    
    idx     = ~isnan(ticklat);
    ticklon = ticklon(idx);
    ticklat = ticklat(idx);
    
    if sum(idx) >= 1
        
        % Plot grid line:
        ll = plot(ticklat, ticklon,grid_style,'LineWidth',.5);
        ll.Color = [.15,.15,.15,grid_alpha];
        
        % Determine if current grid line crosses X-Axis:
        dist_axis  =  ticklon(1) - y_lim(1);
        crosses_ax = abs(dist_axis) < diff(y_lim)*0.01;
        
        %disp([num2str(aux_lon) '  :  crosses = '  num2str(crosses_ax) '   diff=' num2str(abs(ticklat(1) - y_lim(1)))])
        
        if crosses_ax
            ticks_x(i) = ticklat(1);
            if aux_lon < 0
                degr = [num2str(abs(aux_lon)) char(176) 'W'];
            elseif aux_lon == 0
                degr = [num2str(abs(aux_lon))  char(176)];
            elseif aux_lon > 0
                degr = [num2str(abs(aux_lon))  char(176) 'E'];
            end
            tlabs_x{i}  = degr;
        end
        
        ll = plot(ticklat,ticklon,grid_style,'LineWidth',.5);
        ll.Color = [.15,.15,.15,grid_alpha];
        
    end

end

idx          = ticks_x==0;
ticks_x(idx) = [];
tlabs_x(idx) = [];

% =====================================================================================

set(gca,'XTick',ticks_x,'XTickLabel',tlabs_x)
set(gca,'YTick',ticks_y,'YTickLabel',tlabs_y)
set(gca,'TickDir','out')
set(gca,'TickLength',[0 0])
grid off









































